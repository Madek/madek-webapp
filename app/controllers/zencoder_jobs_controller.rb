class ZencoderJobsController < ApplicationController

  # Disable CSRF protection because this is only called by an external service
  # We do sanity checking in action itself and only accept answers we expect.
  protect_from_forgery with: :null_session

  def notification
    # find Job, fail 404 if unknown
    @zencoder_job = ZencoderJob.find(params[:id])

    begin
      # get job details from helper gem
      details = Zencoder::Job.details(params[:job][:id]).body

      if @zencoder_job.state == 'submitted'
        @zencoder_job.update_attributes(
          notification: details
        )
        import_thumbnails(details)
        import_previews(details)
        @zencoder_job.update_attributes(
          state: 'finished',
          progress: 100.0
        )
      end

    rescue => e
      @zencoder_job.update_attributes(state: 'failed', error: e.to_s)
    ensure
      render nothing: true
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
    details['job']['output_media_files'].each do |output_file|
      case @zencoder_job.media_file.content_type
      when /video/
        import_video_preview(output_file) if finished?(output_file)
      when /audio/
        import_audio_preview(output_file) if finished?(output_file)
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
      thumbnail: 'large'
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
      audio_codec: output_file['audio_codec']
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
