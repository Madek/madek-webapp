module CIJobs

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


    ### Commands #################################################################################
  
    def setup_ci_shell_commands 
      @setup_ci_shell_commands ||= File.read Rails.root.join 'lib','ci','pre_job_shell_commands.sh'
    end

    def post_job_shell_commands
      @post_job_shell_commands ||= File.read Rails.root.join 'lib','ci','post_job_shell_commands.sh'
    end

    def aggregator_shell_commands
      setup_ci_shell_commands + 'bundle exec rake madek:ci:query_all_success AUTH_FILE=/var/lib/jenkins/configs/api_credentials.yml'
    end

    def creator_shell_commands
      setup_ci_shell_commands + 'bundle exec rake madek:ci:create_or_update_all_jobs  AUTH_FILE=/var/lib/jenkins/configs/api_credentials.yml'
    end


    def cucumber_ci_shell_commands
      setup_ci_shell_commands + 'bundle exec rake madek:test:cucumber:all FILE=$FILE '
    end

    def rspec_ci_shell_commands
      setup_ci_shell_commands + 'bundle exec rspec $FILE'
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

    ################################################################
    ### TEMPLATE XML
    ################################################################

    def prepare_template_for_job branch_name
      xml_doc = REXML::Document.new(File.new Rails.root.join "lib","ci","job_template.xml")

      REXML::XPath.first(xml_doc,  \
                         "/project/publishers/hudson.plugins.postbuildtask.PostbuildTask/tasks/hudson.plugins.postbuildtask.TaskProperties/script") \
                         .text= post_job_shell_commands

      REXML::XPath.first(xml_doc,  \
                         "/project/scm/branches/hudson.plugins.git.BranchSpec/name") \
                         .text= branch_name

      REXML::XPath.first(xml_doc,  \
                         "/project/publishers/hudson.tasks.BuildTrigger/childProjects") \
                         .text= aggregator_job_name(branch_name)

      xml_doc
    end


    def prepare_template_for_task branch_name
      xml_doc = REXML::Document.new(File.new Rails.root.join "lib","ci","task_template.xml")

      REXML::XPath.first(xml_doc,  \
                         "/project/publishers/hudson.plugins.postbuildtask.PostbuildTask/tasks/hudson.plugins.postbuildtask.TaskProperties/script") \
                         .text= post_job_shell_commands

      REXML::XPath.first(xml_doc,  \
                         "/project/scm/branches/hudson.plugins.git.BranchSpec/name") \
                         .text= branch_name


      REXML::XPath.first(xml_doc,"/project/disabled").text= "false"
      REXML::XPath.first(xml_doc, "/project/assignedNode").text= "master"

      xml_doc
    end


    
    ###############################################################
    ### CREATE AGGREGATOR JOB XML
    ###############################################################
    def create_new_job_aggregtor! branch_name

      xml_doc = prepare_template_for_task branch_name

      REXML::XPath.first(xml_doc, \
                         "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent") \
                         .text= %Q[\nRAILS_ENV=test \nBRANCH_NAME=#{branch_name} \nCI_TEST_NAME=#{branch_name.downcase}_aggregator]

      REXML::XPath.first(xml_doc,  \
                         "/project/builders/hudson.tasks.Shell/command") \
                         .text= aggregator_shell_commands()

      create_ci_job!(aggregator_job_name(branch_name), xml_doc.to_s) rescue nil
      update_ci_job!(aggregator_job_name(branch_name), xml_doc.to_s) 

      Rails.logger.info "create_new_job_aggregtor finished without errors"

    end


    def create_new_job_creator! branch_name

      xml_doc = prepare_template_for_task branch_name

      REXML::XPath.first(xml_doc, \
                         "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent") \
                         .text= %Q[\nRAILS_ENV=test \nBRANCH_NAME=#{branch_name} \nCI_TEST_NAME=#{branch_name.downcase}_creator]

      REXML::XPath.first(xml_doc,  \
                         "/project/builders/hudson.tasks.Shell/command") \
                         .text= creator_shell_commands()


      create_ci_job!(creator_job_name(branch_name), xml_doc.to_s) rescue nil
      update_ci_job!(creator_job_name(branch_name), xml_doc.to_s) 

      Rails.logger.info "create_new_job_creator finished without error"

    end


    ### JOBS and JOB HELPERS ##################################################################
  

    def all_rspec_jobs_params branch_name = ENV['BRANCH_NAME'] 
      raise 'env BRANCH_NAME is required' unless branch_name 
      Dir.glob("spec/*").select{|d| Dir.exists? d}.reject{|d| d =~ /spec\/javascripts/}.map do |name|
        { filename: name,
          runner: 'rspec',
          name: name.gsub(/\//,'__'),
          branch_name: branch_name, 
          ci_name: "#{branch_name}__#{name.gsub(/\//,'__')}"
        }
      end.sort_by{|h| h[:name]}
    end

    def all_feature_jobs_params branch_name = ENV['BRANCH_NAME'] 
      unless branch_name 
        raise 'env BRANCH_NAME is required'
      else
        Dir.glob("features/**/*.feature").map do |filename| 
          { filename: filename,
            runner: 'cucumber',
            name: File.basename(filename,".feature"),
            branch_name: branch_name ,
            ci_name: "#{branch_name}__feature__#{File.basename(filename,".feature")}"
          }
        end.sort_by{|h| h[:name]}
      end
    end

    def all_jobs branch_name = ENV['BRANCH_NAME'] 
      (all_feature_jobs_params(branch_name) + all_rspec_jobs_params(branch_name)) \
        .sort_by{|h| h[:name]}
    end

    def job_env job_params
      "RAILS_ENV=test\nCI_TEST_NAME=#{job_params[:ci_name].downcase}\nFILE=#{job_params[:filename]}  \nCAPYBARA_WAIT_TIME=30"
    end

    def ci_job_name job_params
      "#{BASE_NAME}_#{job_params[:ci_name]}"
    end

    def job_xml job_params, xml_doc
      REXML::XPath.first(xml_doc, "/project/buildWrappers/EnvInjectBuildWrapper/info/propertiesContent").text=
        job_env(job_params)

      REXML::XPath.first(xml_doc,  \
                         "/project/builders/hudson.tasks.Shell/command") \
                         .text= case job_params[:runner]
                                when 'cucumber'
                                  cucumber_ci_shell_commands()
                                when 'rspec'
                                  rspec_ci_shell_commands()
                                else
                                  raise "not supported" 
                                end


      REXML::XPath.first(xml_doc, "/project/disabled").text="false"
      xml_doc.to_s
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

    def list_all_jobs opts = {}
      response = create_connection(opts).get("/view/All/api/json")
      if response.status >= 300
        raise "list_all_jobs failed with #{response.status}" 
      else
        JSON.parse(response.body)['jobs']
      end
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

    def create_connection opts = {}
      Faraday.new(url: BASE_PATH) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth(opts_or_env(:ci_user,opts), opts_or_env(:ci_pw,opts))
      end
    end

    def update_ci_job! job_name, xml, opts = {}
      unless (200..299).include? create_connection(opts).get("job/#{job_name}/config.xml").status
        Rails.logger.debug "will not update the job #{job_name} since it does not exist in the first place"
      else
        response = create_connection(opts).post do |req|
          req.path= "job/#{job_name}/config.xml"
          req.headers['Content-Type'] = 'application/xml'
          req.body = xml
        end
        raise "Updating the job #{job_name} failed with #{response.status}" if response.status >= 400
        response
      end
    end

    def create_ci_job! job_name, xml, opts = {}
      if (200..299).include? create_connection(opts).get("job/#{job_name}/config.xml").status
        Rails.logger.debug "will not create the job #{job_name} since it exist already"
      else
        resp = create_connection(opts).post do |req|
          req.path= "/createItem"
          req.params['name'] = job_name 
          req.headers['Content-Type'] = 'application/xml'
          req.body = xml
        end
        raise "create_ci_job #{job_name} failed with #{resp.status}" if resp.status >= 400
        resp
      end
    end

    def create_or_update_all_jobs!  opts = {}
      all_jobs.each do |job_params|
        xml_doc = prepare_template_for_job(opts[:branch_name] || ENV['BRANCH_NAME'])
        xml_config = job_xml(job_params, xml_doc)
        create_ci_job! ci_job_name(job_params), xml_config, opts rescue nil
        update_ci_job! ci_job_name(job_params), xml_config, opts
        Rails.logger.info "the job #{ci_job_name(job_params)} has been created w.o. errors"
      end
      exit 0
    end

    def get_last_build_status_of_all_jobs opts={}
      add_success_status_to_all_jobs(
        all_jobs.map do |job_params|
        job_params.merge({
          ci_last_build: 
          begin
            url = "/job/#{ci_job_name(job_params)}/lastBuild/api/json"
            response = create_connection(opts).get(url)
            if response.status >= 300 
              raise "get #{url} failed with #{response.status}"
            else 
              JSON.parse(response.body).symbolize_keys!
            end
          end
        })      
        end
      )
    end

    def all_success? builds
      builds.map{|h| h[:is_success]}.all?
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
