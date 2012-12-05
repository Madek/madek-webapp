namespace :madek do
  namespace :ci do

    desc "Create the aggregator and template of a new branch to be tested, requires BRANCH_NAME, CI_USER and CI_PW  env variables"
    task :create_branch do
      CIFeatureJobs.create_new_job_aggreagtor! ENV['BRANCH_NAME']
      CIFeatureJobs.create_new_job_creator! ENV['BRANCH_NAME']
      CIFeatureJobs.create_new_job_template! ENV['BRANCH_NAME']
    end
  
    desc "Delete jobs by matcing a regular expression; requires REX, CI_USER and CI_PW env variables" 
    task :delete_jobs_by_regex do

      raise "you must provide non empty REX parameter"  unless rex=ENV['REX'] and (not rex.empty?)

      jobs = CIFeatureJobs.filter_jobs_by_regex rex
      if jobs.size < 1
        puts "no job mached your query, so I don't do anything"
      else
        puts jobs.map{|j| j['name']}.join("\n")
        puts "Confirm the deletion of the #{jobs.size} listed jobs by typing YES"
        if /^YES/ =~  STDIN.gets
          res = CIFeatureJobs.delete_jobs jobs 
          puts res.map{|job| "#{job[:status]} #{job['name']}"}.join("\n")
        end
      end
    end

    desc "Updates and (creates when needed) all feature jobs; requires CI_USER and CI_PW env variables, or a AUTH_FILE"
    task :create_or_update_all_feature_jobs do
      opts = 
        begin 
          YAML::load_file(ENV['AUTH_FILE']).symbolize_keys
        rescue 
          {}
        end
      CIFeatureJobs.create_or_update_all_jobs! opts
    end

    desc "Checks if all features habe been built successfully" 
    task :query_all_features_success do
      last_job_builds = CIFeatureJobs.get_last_build_status_of_all_jobs
      if CIFeatureJobs.all_features_success? last_job_builds
        exit 0
      else
        puts last_job_builds.select{|h| not h[:is_success]}.to_yaml
        exit -1
      end
    end

  end
end
