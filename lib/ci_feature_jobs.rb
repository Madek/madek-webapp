module CIFeatureJobs

  require 'rexml/document'

  BASE_PATH = "http://ci.zhdk.ch"
  BASE_NAME = "MAdeK_AT_"

  class << self

    ### HELPERS ###############################################################################

    def reload! 
      load Rails.root.join(__FILE__)
    end

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def opts_or_env symb, opts = {}
      opts[symb] || opts[symb.to_s] || ENV[symb.to_s.upcase]
    end

    ### CREATE NEW JOB TEMPLATE and  AGGREGATOR ##################################################
    
    def job_template_name branch_name = ENV['BRANCH_NAME']
      "#{BASE_NAME}_#{branch_name}___TEMPLATE"
    end

    def template_url branch_name = ENV['BRANCH_NAME']
      "#{BASE_PATH}/job/#{job_template_name}/config.xml"
    end

    def aggregator_job_name branch_name
      "#{BASE_NAME}_#{branch_name}___AGGREGATOR"
    end

    def creator_job_name branch_name
      "#{BASE_NAME}_#{branch_name}___CREATOR"
    end
    
    def create_new_job_template! branch_name, job_template_xml_doc = \
      REXML::Document.new(File.new Rails.root.join "lib","ci","job_template.xml")

      REXML::XPath.first(job_template_xml_doc,  \
                         "/project/scm/branches/hudson.plugins.git.BranchSpec/name") \
                         .text= branch_name

      REXML::XPath.first(job_template_xml_doc,  \
                         "/project/publishers/hudson.tasks.BuildTrigger/childProjects") \
                         .text= aggregator_job_name(branch_name)

      # this seems the only way to get it up reliably
      create_ci_job!(job_template_name(branch_name), job_template_xml_doc.to_s) rescue nil
      update_ci_job!(job_template_name(branch_name), job_template_xml_doc.to_s) rescue nil

    end

    def create_new_job_aggreagtor! branch_name, aggregator_xml_doc = \
      REXML::Document.new(File.new Rails.root.join "lib","ci","aggregator.xml")
      
      REXML::XPath.first(aggregator_xml_doc,  \
                         "/project/scm/branches/hudson.plugins.git.BranchSpec/name") \
                         .text= branch_name

      REXML::XPath.first(aggregator_xml_doc, \
                         "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent") \
                         .text= %Q[\nRAILS_ENV=test \nBRANCH_NAME=#{branch_name} \n]

      create_ci_job!(aggregator_job_name(branch_name), aggregator_xml_doc.to_s) rescue nil
      update_ci_job!(aggregator_job_name(branch_name), aggregator_xml_doc.to_s) rescue nil
    end


    def create_new_job_creator! branch_name, xml_doc = \
      REXML::Document.new(File.new Rails.root.join "lib","ci","creator.xml")
      
      REXML::XPath.first(xml_doc,  \
                         "/project/scm/branches/hudson.plugins.git.BranchSpec/name") \
                         .text= branch_name

      REXML::XPath.first(xml_doc, \
                         "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent") \
                         .text= %Q[\nRAILS_ENV=test \nBRANCH_NAME=#{branch_name} \n]

      create_ci_job!(creator_job_name(branch_name), xml_doc.to_s) rescue nil
      update_ci_job!(creator_job_name(branch_name), xml_doc.to_s) rescue nil
    end



    ### JOBS and JOB HELPERS ##################################################################

    def all_jobs_params  basedir = "features", branch_name = ENV['BRANCH_NAME'] 
      unless branch_name 
        raise 'env BRANCH_NAME is required'
      else
        Dir.glob("#{basedir}/**/*.feature").map do |filename| 
          { filename: filename,
            name: File.basename(filename,".feature"),
            branch_name: branch_name }
        end.sort_by{|h| h[:name]}
      end
    end

    def job_env job_params
      "RAILS_ENV=test\nCI_TEST_NAME=#{job_params[:branch_name]}_#{job_params[:name]}\nCUCUMBER_FILE=#{job_params[:filename]}"
    end

    def ci_job_name job_params
      "#{BASE_NAME}_#{job_params[:branch_name]}__#{job_params[:name]}"
    end

    def job_xml job_params, template_xml = template_xml()
      doc = REXML::Document.new template_xml
      REXML::XPath.first(doc, "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent").text=
        job_env(job_params)
      REXML::XPath.first(doc, "/project/disabled").text="false"
      doc.to_s
    end

    def template_xml reload = false , opts = {}
      (!reload and @template_xml) ||  @template_xml = begin
        RestClient::Request.new( \
          method: :get, 
          url: template_url, 
          user: opts_or_env(:ci_user,opts), 
          password: opts_or_env(:ci_pw,opts)).execute
      end
    end

    #############################################################################
    ### CI API ##################################################################
    #############################################################################
    
  
    ### list and delete jobs #################
     
    def list_all_jobs
      JSON.parse(RestClient.get "#{BASE_PATH}/view/All/api/json")['jobs']
    end

    def filter_jobs_by_regex strex, jobs = list_all_jobs 
      r = Regexp.new strex
      jobs.select{|j| r.match j['name']}
    end

    def delete_jobs jobs, opts = {}
      jobs.map do |job|
        resp = create_connection(opts).post do |req|
          req.path= "job/#{job['name']}/doDelete"
          req.body= ''
        end
        job.merge status: resp.env[:status] 
      end
    end

    ###########################################

    def create_connection opts
      Faraday.new(url: BASE_PATH) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth(opts_or_env(:ci_user,opts), opts_or_env(:ci_pw,opts))
      end
    end

    def update_ci_job! job_name, xml, opts = {}
      create_connection(opts).post do |req|
        req.path= "job/#{job_name}/config.xml"
        req.headers['Content-Type'] = 'application/xml'
        req.body = xml
      end
    end

    def create_ci_job! job_name, xml, opts = {}
      create_connection(opts).post do |req|
        req.path= "/createItem"
        req.params['name'] = job_name 
        req.headers['Content-Type'] = 'application/xml'
        req.body = xml
      end
    end

    def create_or_update_all_jobs!  opts = {}
      all_jobs_params.each do |job_params|
        xml =  template_xml reload = false , opts
        xml_config = job_xml job_params, xml
        begin
          create_ci_job! ci_job_name(job_params), xml_config, opts
        rescue
        end
        begin
          resp = update_ci_job! ci_job_name(job_params), xml_config, opts
        rescue => e
          puts "update error: #{e}"
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
