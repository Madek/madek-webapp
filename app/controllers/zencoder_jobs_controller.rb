class ZencoderJobsController < ApplicationController
  def notification
    @zencoder_job = ZencoderJob.find(params[:id])

    details = Zencoder::Job.details(params[:job][:id]).body

    if @zencoder_job.state == 'submitted'
      @zencoder_job.update_attributes(
        notification: details
      )
      import_thumbnails(details)
      import_previews(details)
      @zencoder_job.update_attributes(state: 'finished')
    end

  rescue => e
    @zencoder_job.update_attributes(state: 'failed', error: e.to_s)
  ensure
    render nothing: true
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
    thumb_size = thumbnail['width']
    content_type = 'image/' + format_mapping(thumbnail)
    target_file = "#{media_file.thumbnail_store_location}_#{thumb_size}.jpg"

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
    content_type = "audio/#{output_file['format']}"
    target_file =
      "#{media_file.thumbnail_store_location}.#{output_file['format']}"

    download_file(url, target_file)
    media_file.previews.create!(
      content_type: content_type,
      filename: target_file.split('/').last
    )
  end

  def download_file(url, target_file)
    uri = URI.parse(url)
    source_path = [uri.path, uri.query].join('?')

    Net::HTTP.start(uri.host) do |http|
      response = http.get(source_path)
      open(target_file, 'wb') do |file|
        file.write(response.body)
      end
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
