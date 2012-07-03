#!/usr/bin/ruby

require 'rubygems'
require 'yaml'
require 'zencoder'
require 'net/ftp'

# documentation: https://github.com/zencoder/zencoder-rb

# use the API builder to build requests: https://app.zencoder.com/api_builder

class EncodeJob

  @@config_path = File.join(Rails.root,"config/zencoder.yml")

  attr_accessor :job_id # Unique job ID that the encoder system (e.g. Zencoder) should assign to us
  attr_accessor :base_url # Output location where finished encodes should be stored
                          # (FTP or SFTP URL including username/password)
  attr_accessor :size    # The target sizes for the encode job. Ignored for audio-only jobs.
  attr_accessor :video_codec  # Usually 'vp8'
  attr_accessor :audio_codec # Usually 'vorbis'
  attr_accessor :job_type # video or audio
  
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
    @video_codec ||= "vp8"
    @audio_codec ||= "vorbis"
    @job_type ||= "video"
    @thumbnails ||= {:thumbnails => {:interval => 60, :prefix => 'frame'}}
    Zencoder.api_key = api_key
  end

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

  # TODO: Add notification callback URLs
  # :notifications => ["http://medienarchiv.zhdk.ch/encode_jobs/notification"]
  
  def start_by_url(url)

    test_mode = 0
    test_mode = 1 if ENCODING_TEST_MODE == 1
    
    options = {:base_url => @base_url, :quality => 4, :speed => 2}
    if @job_type == "video"
      options.merge!(:video_codec => @video_codec).merge!(@size).merge!(@thumbnails)
    elsif @job_type == "audio"
      options.merge!(:audio_codec => @audio_codec, :skip_video => 1)
    end
    
    outputs = [options]  # You can chain more outputs onto this array
    
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

  # Not THAT useful, we should instead extract all info we need manually from +details+
  def encoded_file_urls
    paths = []
    details['output_media_files'].each do |file|
      paths << file['url']
    end
    return paths
  end
  
  def thumbnail_file_urls
    paths = []
    details['thumbnails'].each do |tn|
      paths << tn['url']
    end
    return paths
  end
  
  def self.ftp_get(source_url, target_filename)
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

  def self.http_get(source_url, target_filename)
    require 'net/http'
    request = Net::HTTP::Get.new uri.request_uri

    http.request request do |response|
      open target_filename, 'wb' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
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
