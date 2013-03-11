class ZencoderJob < ActiveRecord::Base
  belongs_to :media_file
  serialize :notification, JsonSerializer
  serialize :request, JsonSerializer
  serialize :response, JsonSerializer

  attribute_names.map(&:to_sym).each{|att| attr_accessible att}
  attr_accessible :media_file


  before_create do |model|
    model.id ||= SecureRandom.uuid 
  end

  default_scope order("zencoder_jobs.created_at ASC")

  ################################################################
  # config
  ################################################################

  def config
    @config ||=  \
      YAML.load_file(ENV['ZENCODER_CONFIG_FILE'] || \
                     Rails.root.join("config","zencoder.yml")) rescue nil
  end

  def config_api_key
    config.try(:[],'zencoder').try(:[],'api_key')
  end

  def config_ftp
    config.try(:[],'zencoder').try(:[],'ftp_base_url')
  end

  ################################################################
  # submit and send to zencoder
  ################################################################

  def submit 
    begin 

      raise "Illegal State Error, state must be initialized" if state != 'initialized'

      update_attributes request: \
        case Rails.env
        when "production", "test"
          build_zencoder_request
        when "development" 
          build_zencoder_request_for_development
        end

      # send the request to zencoder
      case Rails.env
      when "production", "development"
        send_request_to_zencoder
      when "test" 
        update_attributes state: 'submitted', comment: "Running in test mode, job is not really submitted" 
      else
        update_attributes state: 'failed', comment: "Running in unknown mode." 
      end

    rescue => e
      update_attributes state: 'failed', error: (e.message.to_s + "\n\n" + e.backtrace.join("\n"))
    end

  end


  def send_request_to_zencoder
    begin

      if config_api_key
        Zencoder.api_key = config_api_key 
      else
        raise "Zencoder API key is mandatory for submitting to Zencoder.com"
      end

      if(response = Zencoder::Job.create(request)).success?
        update_attributes state: 'submitted',
          error: nil,
          response: response.body,
          zencoder_id: response.body["id"],
          state: 'submitted'
      else
        update_attributes state: 'failed', error: response.body rescue nil
      end

    rescue => e
      logger.error (e.message.to_s + "\n\n" + e.backtrace.join("\n")) rescue nil
      update_attributes state: 'failed', error: Formatter.error_to_s(e)
    end
  end

  ################################################################
  # build zencoder request
  ################################################################
   
  def build_zencoder_request
    { input: "#{ENCODING_BASE_URL}/media_files/#{media_file.id}?access_hash=#{media_file.access_hash}",
      test: (ENCODING_TEST_MODE == 1) ?  true : false,
      notifications: [notification_url]
    }.merge(build_zencoder_outputs_request)
  end

  def width
    THUMBNAILS[:large].split("x").first.to_i rescue 620
  end

  def build_zencoder_outputs_request
    output_default={label: 'Default', base_url: config_ftp, quality: 4, speed: 2, width: width}
    thumbnails = {interval: 60, width: width, base_url: config_ftp,prefix: self.id, format: "jpg"}

    if media_file.content_type =~ /video/
      output_webm = output_default.merge(format: 'webm', filename: "#{self.id}.webm", label: "webm", thumbnails: thumbnails)
      output_apple = output_default.merge(format: 'mp4', filename: "#{self.id}.mp4", video_codec:  "h264",label: "apple")
      { outputs: [output_webm,output_apple] }
    elsif media_file.content_type =~ /audio/
      { outputs: [output_default.merge(audio_codec: 'vorbis',skip_video: true, filename: "#{self.id}.ogg")]}
    else
      raise "don't know what to with this content_type"
    end
  end

  # will send a notification try: 
  # zencoder_fetcher -c 1 -u http://localhost:3000/zencoder_jobs/JOB_ID/notification API_KEY

  def build_zencoder_request_for_development
    build_zencoder_request.merge(
      input: "http://s3.amazonaws.com/zencodertesting/test.mov", 
      test: true)
  end


  ################################################################
  # progress
  ################################################################

  def progress_per_cent
    if zencoder_id and config_api_key
      Zencoder.api_key = config_api_key
      body= Zencoder::Job.progress(zencoder_id).body
      case body['state']
      when 'waiting'
        0.0
      when 'processing'
        body['progress'].to_f
      when 'finished'
        100.0
      else
        -1
      end
    else
      -1
    end
  end


  ################################################################
  # import previews 
  ################################################################

  def import_previews 
    begin 
      update_attributes state: 'importing'
      notification['outputs'].each do |output|
        if media_file.content_type =~ /video/
          import_preview_movie(output)
          (thumbnails = output['thumbnails']) and thumbnails.each do |thumbnail| 
            thumbnails_previews = thumbnail['images'].map do |image|
              import_preview_thumbnail(image)
            end
            if thumbnail_preview = thumbnails_previews.first
              media_file.thumbnail_jpegs_for thumbnail_preview.full_path
            end
          end
        elsif  media_file.content_type =~ /audio/
          import_preview_audio(output)
        else
          raise "don't know how to import #{media_file.content_type}"
        end
      end
      update_attributes state: 'finished'
    rescue => e
      logger.error e
      update_attributes state: 'failed', error: Formatter.error_to_s(e) rescue nil
      raise e
    end
  end

  def preview_file_name media_file, uri
    media_file.guid + '_' +  uri.path.gsub(/\//,'_')
  end

  def import_preview_audio(output)
    uri = URI.parse(output['url'])
    preview = Preview.create \
      media_file: media_file, 
      content_type: 'audio/' + output['format'],
      filename: preview_file_name(media_file,uri)
    get_ftp_file(uri,preview)
    preview
  end

  def import_preview_movie(output)
    uri = URI.parse(output['url'])
    preview = Preview.create \
      media_file: media_file, 
      height: output['height'],
      width: output['width'],
      content_type: 'video/' + output['format'],
      thumbnail: 'large',
      filename: preview_file_name(media_file,uri)
    get_ftp_file(uri,preview)
    preview
  end

  def format_to_content_type_second_part format
    case format
    when 'jpg'
      'jpeg'
    else
      format
    end
  end

  def import_preview_thumbnail(image)
    uri = URI.parse(image['url'])
    preview = Preview.create \
      media_file: media_file, 
      height: image['dimensions'].split('x').last,
      width: image['dimensions'].split('x').first,
      content_type: 'image/' + format_to_content_type_second_part(image['format'].downcase),
      thumbnail: 'large',
      filename: preview_file_name(media_file,uri)
    get_ftp_file uri,preview
    preview
  end


  def get_ftp_file uri,preview
    require 'net/ftp'
    ftp = Net::FTP.new(uri.host)
    if uri.user and uri.password
      ftp.login(uri.user, uri.password)
    else
      ftp.login
    end
    ftp.getbinaryfile(uri.path, preview.full_path, 1024)
  end



  ################################################################
  # build notification url
  ################################################################

  def notification_url
    url_helpers = Rails.application.routes.url_helpers

    (ENV['URL_HOST_PART'] || "http://zencoderfetcher") + 
      url_helpers.zencoder_job_notification_path(self)
  end



  ################################################################
  # class methods
  ################################################################

  class << self
    def create_zencoder_jobs_if_applicable media_resources
      media_resources.joins(:media_file) \
        .where("media_files.content_type SIMILAR TO '%(video|audio)%' ").map do |mr| 
          ZencoderJob.create media_file:  mr.media_file
        end
    end
  end

end
