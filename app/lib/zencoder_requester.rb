class ZencoderRequester
  def initialize(media_file)
    @media_file = media_file
  end

  def process
    unless File.exist?(@media_file.original_store_location)
      raise "Input file doesn't exist"
    end

    if Settings.zencoder_enabled
      unless Zencoder.api_key
        raise 'Zencoder API key is mandatory for submitting to Zencoder.com'
      end
      @zencoder_job = ZencoderJob.create(media_file: @media_file)
      create_zencoder_job
    else
      raise 'Zencoder is not enabled! Check your zencoder configuration!'
    end
  end

  private

  def create_zencoder_job
    @zencoder_job.update_attributes(
      request: request_params
    )

    if (response = Zencoder::Job.create(request_params)).success?
      @zencoder_job.update_attributes(
        state: 'submitted',
        response: response.body,
        zencoder_id: response.body['id']
      )
    else
      @zencoder_job.update_attributes(
        state: 'failed',
        error: response.try(:body)
      )
    end
  end

  def request_params
    input_param = host_name +
      url_helpers.media_file_path(@media_file,
                                  access_hash: @media_file.access_hash)
    params = {
      input: input_param,
      notifications: [notification_url]
    }

    params.merge!(test: Settings.zencoder_test_mode)
    params.merge!(output_settings)
  end

  def output_settings
    defaults = {
      label: 'Default',
      quality: 4,
      speed: 2,
      width: width
    }

    outputs =
      case @media_file.content_type
      when /video/ then video_output_settings
      when /audio/ then audio_output_settings
      else []
      end

    defaults.merge(outputs: outputs)
  end

  def video_output_settings
    Settings.zencoder_video_output_formats_defaults.map do |output|
      output = output.to_hash
      if output[:thumbnails]
        output[:thumbnails] = video_thumbnails_settings
      end
      output.merge(filename: "#{@media_file.id}.#{output[:format]}")
    end
  end

  def audio_output_settings
    [
      Settings.zencoder_audio_output_formats_defaults.first.to_hash.merge(
        filename: "#{@media_file.id}.ogg"
      )
    ]
  end

  def video_thumbnails_settings
    Settings.zencoder_video_thumbnails_defaults.to_hash.merge(
      prefix: @media_file.id
    )
  end

  def notification_url
    host_name + url_helpers.zencoder_job_notification_path(@zencoder_job)
  end

  def host_name
    'http://' + (Settings.madek_host_name || ENV['HOST_NAME'])
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def width
    Madek::Constants::THUMBNAILS[:large].fetch(:width, 620)
  end
end
