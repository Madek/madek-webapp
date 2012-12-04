#!/usr/bin/ruby

require 'rubygems'
require 'yaml'
require 'zencoder'
require 'net/ftp'

# documentation: https://github.com/zencoder/zencoder-rb

# use the API builder to build requests: https://app.zencoder.com/api_builder

# @author Ramón Cahenzli <rca@psy-q.ch>
class EncodeJob
  @@config_path = File.join(Rails.root,"config/zencoder.yml")

  # Unique job ID that the encoder system (e.g. Zencoder) should assign to us
  # @return [Integer]
  attr_accessor :job_id 

  # Output location where finished encodes should be stored. FTP or SFTP URL including username/password.
  # @return [String]
  # @example 
  #   "http://foo:bar@ftp.foo.com/encoded"
  attr_accessor :base_url

  # The target sizes for the encode job. Ignored for audio-only jobs.
  # @return [String]
  # @example 
  #   "640x480"
  # @see https://app.zencoder.com/docs/api/encoding/resolution/size
  attr_accessor :size

  # Audio codec to use. Usually this is 'vorbis' (Ogg Vorbis)
  # @return [String]
  # @example
  #   "vorbis"
  # @see https://app.zencoder.com/docs/api/encoding/format-and-codecs/audio-codec
  attr_accessor :audio_codec

  # Whether this is a video or an audio job. For audio jobs, video settings are
  # ignored.
  # @return [String]
  # @example Setting for a video job
  #   "video"
  # @example Setting for an audio job
  #   "audio"
  attr_accessor :job_type # video or audio

  # Initialize with some necessary defaults, such as usable audio and video codecs.
  # This is done in the constructor so that when we fire off a new job at Zencoder, we're
  # reasonably sure that it has a valid configuration by default.
  #
  # @example job = EncodeJob.new("12347727983")
  # @param [Integer] job_id Job ID as returned by Zencoder's API
  # @return nil
  def initialize(job_id = nil)

    raise 'Configuration @@config_path not found or malformed.' unless configured?

    @job_id = job_id unless job_id.nil?
    config = YAML::load(File.open(@@config_path))
    api_key = config['zencoder']['api_key']
    @base_url = config['zencoder']['ftp_base_url']
    begin
      max_width = THUMBNAILS[:large].split("x").first
    rescue
      # If THUMBNAILS is undefined, the previous statement will raise a NameError, so let's set the width here
      max_width = 620
    ensure
      # And if it hasn't been set until now, let's set a reasonable default
      max_width ||= 620
    end
    @size ||= { :width => max_width }
    @audio_codec ||= "vorbis"
    @job_type ||= "video"
    @thumbnails ||= {:thumbnails => {:interval => 60, :prefix => 'frame'}}
    Zencoder.api_key = api_key
  end

  # Checks if there is a Zencoder API key and FTP base URL in a configuration file (by default
  # this is config/zencoder.yml). If everything *seems* OK, returns true. Note that just because
  # the configuration is OK, there can be other things stopping the encode from working (e.g.
  # network not reachable, wrong API key, unreachable FTP destination...)
  # @return [Boolean]
  def configured?
    configured = false
    if File.exists?(@@config_path)
      config = YAML::load(File.open(@@config_path))
      if config['zencoder'] && config['zencoder']['api_key'] && config['zencoder']['ftp_base_url']
        configured = true
      end
    end
    return configured
  end

  # @param [String] url The publicly-accessible URL of the file you want encoded.
  def start_by_url(url)
    # TODO: Add notification callback URLs
    # :notifications => ["http://medienarchiv.zhdk.ch/encode_jobs/notification"]
    test_mode = 0
    test_mode = 1 if ENCODING_TEST_MODE == 1

    options = {:base_url => @base_url, :quality => 4, :speed => 2}
    if @job_type == "video"
      webm_options = options.clone
      webm_options.merge!(:video_codec => "vp8").merge!(@size).merge!(@thumbnails)
      # Apple uses nonstandard formats and codecs, so we need to add a specific Apple-only option
      apple_options = options.clone
      apple_options.merge!(:format => 'mp4', :video_codec => "h264").merge!(@size).merge!(@thumbnails)
    elsif @job_type == "audio"
      options.merge!(:audio_codec => @audio_codec, :skip_video => 1)
    end

    if @job_type == "video"
      outputs = [webm_options, apple_options]
    elsif @job_type == "audio"
      outputs = [options]  # You can chain more outputs onto this array
    end

    settings = {:test => test_mode,
                :input => url,
                :outputs => outputs}

    response = Zencoder::Job.create(settings)
    if response.success?
      @job_id = response.body['id']
      return true
    else
      @job_id = nil
      return false
    end
  end

  def details
    Zencoder::Job.details(@job_id).body['job']
  end

  def progress
    Zencoder::Job.progress(@job_id).body
  end

  def state
    details['state']
  end

  def finished?
    state == "finished"
  end

  # @return [Array] Array of URLs (strings) of the encoded files.
  def encoded_file_urls
    paths = []
    details['output_media_files'].each do |file|
      paths << file['url']
    end
    return paths
  end

  # @return [Array] Array of URLs (strings) of the thumbnails extracted during encoding (only for video jobs)
  def thumbnail_file_urls
    paths = []
    details['thumbnails'].each do |tn|
      paths << tn['url']
    end
    return paths
  end

  # @param [String] source_url URL of the file to retrieve by FTP. Must include username and password if necessary.
  # @param [String] target_filename The filename (full, absolute path) where you want to store the retrieved file.
  # @option options [Boolean] :delete_after (false) Delete the files from the FTP server after retrieval
  def self.ftp_get(source_url, target_filename, options = {:delete_after => false})
    require 'net/ftp'
    uri = URI.parse(source_url)
    if uri.scheme == "ftp"
      ftp = Net::FTP.new(uri.host)

      if uri.user and uri.password
        ftp.login(uri.user, uri.password)
      else
        ftp.login
      end

      begin
        result = ftp.getbinaryfile(uri.path, target_filename, 1024)
        if result == true and options[:delete_after] == true
          ftp.delete(uri.path)
        end
        ftp.close
      rescue
        # Usually some filesystem error happened, can't write to file, or I can't reach the host etc.
        # We catch all of these here. If we ever want finer-grained errors, we have to implement them error by error.
        result = false
      end

      if result == nil
        return true
      else
        return false
      end
    else
      raise "This method handles only FTP URLs."
    end
  end

  # @param [String] source_url URL of the file to retrieve by HTTP. Must include username and password if necessary.
  # @param [String] target_filename The filename (full, absolute path) where you want to store the retrieved file.
  def self.http_get(source_url, target_filename)
    require 'net/http'
    uri = URI.parse(source_url)

    begin
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri.request_uri
        http.request request do |response|
          open target_filename, 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
      return true
    rescue
      # So that callers know something went wrong. We must handle the proper exceptions above
      return false
    end
  end


end



# Example use follows
# job = EncodeJob.new
# 
# response = job.start_by_url("http://medienarchiv.zhdk.ch/encode/grumpy_cat.mp4")
# 
# puts job.details.inspect


#Zencoder.api_key = 'abcd1234'
#response = Zencoder::Job.list
