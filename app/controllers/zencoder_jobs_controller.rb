class ZencoderJobsController < ApplicationController

  # Disable CSRF protection because this is only called by an external service
  # We do sanity checking in action itself and only accept answers we expect.
  protect_from_forgery with: :null_session

  def notification
    skip_authorization
    # find Job, fail 404 if unknown
    @zencoder_job = ZencoderJob.find(params[:id])

    begin
      # get job details from helper gem
      details = Zencoder::Job.details(params[:job][:id]).body

      if @zencoder_job.state == 'submitted'
        @zencoder_job.update(
          notification: details
        )
        import_thumbnails(details)
        import_previews(details)
        collect_finished_profiles(details)
        @zencoder_job.update(
          state: 'finished',
          progress: 100.0
        )
      end

    rescue => e
      @zencoder_job.update(state: 'failed', error: e.to_s)
    ensure
      head :ok
    end
  end

  private

  def media_file
    @zencoder_job.media_file
  end

  def import_thumbnails(details)
    details['job']['thumbnails'].each do |thumbnail|
      case media_file.content_type
      when /video/
        media_file.create_previews!(
          import_video_thumbnail(thumbnail).file_path
        )
      end
    end
  end

  def import_previews(details)
    hls_outputs = []
    details['job']['output_media_files'].each do |output_file|
      if output_file['label'].to_s.start_with?('hls')
        hls_outputs << output_file if finished?(output_file)
        next
      end

      case @zencoder_job.media_file.content_type
      when /video/
        import_video_preview(output_file) if finished?(output_file)
      when /audio/
        import_audio_preview(output_file) if finished?(output_file)
      end
    end
    import_hls(hls_outputs)
  end

  def import_hls(outputs)
    playlist = outputs.find { |output| output['label'].to_s == 'hls' }
    return unless playlist

    Dir.mktmpdir('madek-hls') do |dir|
      stage_hls(outputs, playlist, dir)
      HlsPackage.new(media_file).import!(dir)
    end
  rescue => e
    Rails.logger.error "HLS IMPORT ERR: #{e.inspect}, #{e.backtrace}"
  end

  def stage_hls(outputs, playlist, dir)
    if zip_url?(playlist['url'])
      zip = File.join(dir, 'package.zip')
      download_file!(playlist['url'], zip)
      extract_zip(zip, dir)
      FileUtils.rm_f(zip)
      hoist_master!(dir)
      return
    end

    outputs.each do |output|
      name = hls_output_name(output['label'])
      next unless name && output['url'].present?

      path = File.join(dir, name)
      download_file!(output['url'], path)
      fetch_playlist_assets(output['url'], path, dir) if name.end_with?('.m3u8')
    end
    hoist_master!(dir)
  end

  def hls_output_name(label)
    {
      'hls' => 'master.m3u8',
      'hls_360' => '360.m3u8',
      'hls_720' => '720.m3u8',
      'hls_1080' => '1080.m3u8'
    }[label.to_s]
  end

  def zip_url?(url)
    path = URI.parse(url.to_s).path
    File.extname(path) == '.zip'
  rescue URI::InvalidURIError
    false
  end

  def extract_zip(zip_path, dir)
    require 'zip'
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        next if entry.directory?

        name = entry.name.sub(%r{\A/+}, '')
        raise 'unsafe zip entry' if name.empty? || name.split('/').include?('..')

        dest = File.join(dir, name)
        FileUtils.mkdir_p(File.dirname(dest))
        entry.extract(dest) { true }
      end
    end
  end

  def hoist_master!(dir)
    return if File.file?(File.join(dir, 'master.m3u8'))

    found = Dir.glob(File.join(dir, '**', 'master.m3u8')).first
    return unless found

    source_root = File.dirname(found)
    return if source_root == dir

    Dir.children(source_root).each do |name|
      FileUtils.mv(File.join(source_root, name), File.join(dir, name))
    end
  end

  def fetch_playlist_assets(page_url, playlist_path, dir, seen = {})
    text = File.read(playlist_path)
    referenced_playlist_uris(text).each do |uri|
      next if uri.match?(%r{\A[a-z]+:}i) && !uri.match?(%r{\Ahttps?://}i)

      name = File.basename(uri.split('?').first)
      next if name.empty? || seen[name]

      seen[name] = true
      dest = File.join(dir, name)
      unless File.file?(dest) && File.size(dest).positive?
        download_file!(URI.join(page_url, uri).to_s, dest)
      end
      fetch_playlist_assets(URI.join(page_url, uri).to_s, dest, dir, seen) if name.end_with?('.m3u8')
    end
  end

  def referenced_playlist_uris(text)
    uris = []
    text.scan(/URI="([^"]+)"/) { uris << Regexp.last_match(1) }
    text.each_line do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?('#')

      uris << stripped
    end
    uris.uniq
  end

  def download_file!(url, target_file)
    uri = URI.parse(url)
    FileUtils.mkdir_p(File.dirname(target_file))
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |connection|
      connection.request(Net::HTTP::Get.new(uri)) do |response|
        raise "HLS download #{response.code} #{url}" unless response.is_a?(Net::HTTPSuccess)

        File.open(target_file, 'wb') do |file_stream|
          response.read_body { |chunk| file_stream.write(chunk) }
        end
      end
    end
  end

  def import_video_thumbnail(thumbnail)
    url = thumbnail['url']
    suffix = URI(url).path.split('_').last
    thumb_size = thumbnail['width']
    content_type = 'image/' + format_mapping(thumbnail)
    target_file = "#{media_file.thumbnail_store_location}_#{suffix}"

    download_file(url, target_file)
    media_file.previews.create!(
      content_type: content_type,
      filename: target_file.split('/').last,
      height: thumbnail['height'],
      width: thumb_size,
      thumbnail: 'large'
    )
  end

  def import_video_preview(output_file)
    url = output_file['url']
    content_type = 'video/' + format_mapping(output_file)
    extension = format_mapping(output_file)
    target_file =
      "#{media_file.thumbnail_store_location}_#{output_file['width']}.#{extension}"

    download_file(url, target_file)
    media_file.previews.create!(
      content_type: content_type,
      filename: target_file.split('/').last,
      height: output_file['height'],
      width: output_file['width'],
      thumbnail: 'large',
      conversion_profile: output_file['label']
    )
  end

  def import_audio_preview(output_file)
    url = output_file['url']
    content_type = 'audio/' + output_file['format'].split(' ').first
    extension = File.extname(URI.parse(url).path)
    target_file =
      "#{media_file.thumbnail_store_location}#{extension}"

    download_file(url, target_file)
    media_file.previews.create!(
      content_type: content_type,
      filename: target_file.split('/').last,
      conversion_profile: output_file['label']
    )
  end

  def download_file(url, target_file)
    uri = URI.parse(url)
    http_opts = { use_ssl: (uri.scheme == 'https') }
    download_request = Net::HTTP::Get.new(uri)

    begin
      Net::HTTP.start(uri.host, uri.port, http_opts) do |connection|
        connection.request(download_request) do |response|
          File.open(target_file, 'wb') do |file_stream|
            response.read_body do |download_chunk|
              file_stream.write(download_chunk)
            end
          end
        end
      end
    rescue => e
      Rails.logger.error "ZENCODER IMPORT ERR: #{e.inspect}, #{e.backtrace}"
    end
  end

  def collect_finished_profiles(details)
    profiles = []
    details['job']['output_media_files'].each do |output_file|
      profiles << output_file['label'] if finished?(output_file)
    end
    @zencoder_job.conversion_profiles = profiles.sort
  end

  def finished?(data)
    data['state'] == 'finished'
  end

  def format_mapping(data)
    case data['format']
    when 'jpg' then 'jpeg'
    when 'mpeg4' then 'mp4'
    else data['format']
    end
  end
end
