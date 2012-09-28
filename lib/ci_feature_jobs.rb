module CIFeatureJobs

  TEMPLATE_URL = "http://ci.zhdk.ch/job/MAdeK_next_TEMPLATE/config.xml"
  BASE_PATH = "http://ci.zhdk.ch"
  BASE_NAME = "MAdeK_next_feature"

  class << self

    ### HELPERS ###############################################################################

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def opts_or_env symb, opts = {}
      opts[symb] || opts[symb.to_s] || ENV[symb.to_s.upcase]
    end

    ### JOBS and JOB HELPERS ##################################################################

    def all_jobs_params  basedir = "features"
      Dir.glob("#{basedir}/**/*.feature").map do |filename| 
        { filename: filename,
          name: File.basename(filename,".feature") }
      end.sort_by{|h| h[:name]}
    end

    def job_env job_params
      "RAILS_ENV=test\nCI_TEST_NAME=#{job_params[:name]}\nCUCUMBER_FILE=#{job_params[:filename]}"
    end

    def ci_job_name job_params
      "#{BASE_NAME}_#{job_params[:name]}"
    end

    def job_xml job_params, template_xml = template_xml()
      doc = REXML::Document.new template_xml
      REXML::XPath.first(doc, "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent").text=
        job_env(job_params)
      doc.to_s
    end

    def template_xml reload = false , opts = {}
      (!reload and @template_xml) ||  @template_xml = begin
        RestClient::Request.new( \
          method: :get, 
          url: TEMPLATE_URL, 
          user: opts_or_env(:ci_user,opts), 
          password: opts_or_env(:ci_pw,opts)).execute
      end
    end

    ### CI API ##################################################################

    def create_connection
      Faraday.new(url: BASE_PATH) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth(ENV['CI_USER'], ENV['CI_PW'])
      end
    end

    def update_ci_job! job_params, xml
      create_connection.post do |req|
        req.path= "job/#{ci_job_name(job_params)}/config.xml"
        req.headers['Content-Type'] = 'application/xml'
        req.body = xml
      end
    end

    def create_ci_job! job_params, xml
      create_connection.post do |req|
        req.path= "/createItem"
        req.params['name'] = ci_job_name(job_params)
        req.headers['Content-Type'] = 'application/xml'
        req.body = xml
      end
    end

    def create_or_update_all_jobs! 
      all_jobs_params.each do |job_params|
        xml_config = job_xml job_params
        begin
          create_ci_job! job_params, xml_config
        rescue
        end
        begin
          update_ci_job! job_params, xml_config
        rescue
        end
      end
    end

    def get_last_build_status_of_all_jobs
      add_success_status_to_all_jobs(
        all_jobs_params.map do |job_params|
        job_params.merge({
          ci_last_build: 
          begin
            JSON.parse(RestClient.get("http://ci.zhdk.ch/job/#{ci_job_name(job_params)}/lastBuild/api/json")).symbolize_keys!
          rescue
            nil
          end
        })      
        end
      )
    end

    def all_features_success? buils
      buils.map{|h| h[:is_success]}.all?
    end

   
    ### success ? ####################################################################
    
    def build_is_success? build
      build and build[:result] and build[:result] == "SUCCESS" or false
    end

    def add_success_status_to_all_jobs jobs_with_build
      jobs_with_build.map do |job_info|
        job_info.merge({
          is_success: build_is_success?(job_info[:ci_last_build])
        })
      end
    end

    end
end
