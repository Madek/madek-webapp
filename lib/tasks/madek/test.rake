namespace :madek do

  namespace :test do
    task :run_all do
      Rake::Task["madek:test:setup"].invoke
      Rake::Task["madek:test:rspec"].invoke
      Rake::Task["madek:test:cucumber:all"].invoke
    end

    task :travis do
      Rake::Task["madek:test:setup"].invoke
      Rake::Task["madek:test:rspec"].invoke
    end

    desc "Invoke madek:reset, clean Cucumber files"
    task :setup do
      # Rake seems to be very stubborn about where it takes
      # the RAILS_ENV from, so let's set a lot of options (?)
      Rails.env = 'test'
      task :environment
      # The rspec part of this whole story gets tested against an empty database, so nothing
      # to import from a file here. Instead, we reset based on our migrations.
      Rake::Task["madek:reset"].invoke
      File.delete("tmp/rerun.txt") if File.exists?("tmp/rerun.txt")
      File.delete("tmp/rererun.txt") if File.exists?("tmp/rererun.txt")
    end

    desc "Like setup, but cleans personas and test dbs before, then migrates persona DB. Mostly for use on local machines, not that much use on CI."
    task :setup_local_dbs do
      puts "Terminating connections to 'personas' database"
      DBHelper.terminate_open_connections Rails.configuration.database_configuration["personas"]

      puts "Dropping, creating and migrating 'personas' database to maximum available migration"
      puts `bundle exec rake madek:db:restore_personas_to_max_migration`
      if $?.exitstatus != 0 
        raise "Migrating 'personas' failed."
      end

      puts "Terminating connections to 'test' database"
      DBHelper.terminate_open_connections Rails.configuration.database_configuration["test"]
      puts "Dropping, creating and migrating 'test' database"
      puts `bundle exec rake db:drop db:create db:migrate RAILS_ENV=test`
      if $?.exitstatus != 0 
        raise "Recreating 'test' database failed."
      end

      Rake::Task["madek:test:setup"].invoke
    end

    task :setup_ci_dbs do
      base_config = YAML.load_file Rails.root.join "config","database_jenkins.psql.yml"
      if ENV['CI_TEST_NAME'] 
        base_config['personas']['database'] =  base_config['personas']['database'] + "_" + ENV['CI_TEST_NAME'] 
        base_config['test']['database'] =  base_config['test']['database'] + "_" + ENV['CI_TEST_NAME']
      end
      File.open(Rails.root.join('config','database.yml'),'w'){ |f| f.write base_config.to_yaml}
       ['personas','test'].each do |name|
         db_name = base_config[name]['database']
         DBHelper.set_pg_env base_config[name]
         system "psql -d template1 -c 'DROP DATABASE IF EXISTS \"#{db_name}\";'"
         system "psql -d template1 -c \"CREATE DATABASE \"#{db_name}\" WITH ENCODING 'utf8' TEMPLATE template0;\""
         PersonasDBHelper.load_and_migrate_persona_data
       end
       Rake::Task["db:migrate"].invoke
       Rake::Task["madek:db:restore_personas_to_max_migration"].invoke
    end

    task :rspec do
      system "bundle exec rspec --format d --format html --out tmp/html/rspec.html spec"
      exit_code = $?.exitstatus
      raise "Tests failed with: #{exit_code}" if exit_code != 0
    end

    namespace :cucumber do

      task :all do
        puts "Running all Cucumber tests in one block"
        system "bundle exec cucumber -p all #{ENV['FILE']}"
        exit_code = $?.exitstatus
        puts "First run exited with #{exit_code}"

        rerun_limit = ENV['RERUN_LIMIT'].try(:to_i) || 1
        rerun_count = 0

        while exit_code != 0 and rerun_count < rerun_limit
          system "bundle exec cucumber -p rerun"
          exit_code = $?.exitstatus
          rerun_count += 1
        end

        puts "Final rerun exited with #{exit_code}"
        raise "Tests failed during rerun!" if exit_code != 0

      end

    end
  end

end