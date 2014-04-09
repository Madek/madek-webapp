namespace :madek do
  namespace :db  do

    desc "Terminate all open connections"
    task :terminate_open_connections => :environment do
      DBHelper.terminate_open_connections Rails.configuration.database_configuration[Rails.env]
    end
    task :kill => :terminate_open_connections

    desc "Dump the database in the native adapter format, use DIR or FILE env to specify a destination"
    task :dump => :environment do
      res = DBHelper.dump_native config: Rails.configuration.database_configuration[Rails.env], dir: ENV['DIR'], path: ENV['FILE']
      puts "the data has been dumped into #{res[:path]}"
    end

    desc "Restore the database from native adapter format" 
    task :restore => :environment do
      DBHelper.terminate_open_connections Rails.configuration.database_configuration[Rails.env]
      puts "dropping the db" 
      Rake::Task["db:drop"].invoke
      puts "creating the db"  
      Rake::Task["db:create"].invoke
      DBHelper.restore_native ENV['FILE'], config: Rails.configuration.database_configuration[Rails.env]
    end

    desc "Restore Personas DB (and migrate to the maximal migration version if necessary) and update the persona dump file."
    task :restore_personas_to_max_migration  => :environment do
      PersonasDBHelper.restore_personas_to_max_migration
    end

    desc "Fetch and restore the productive data" 
    task :fetch_and_restore_productive_data => :environment do
      outs = `ssh madek@madek-server "cd current;RAILS_ENV=production DIR=/tmp bundle exec rake madek:db:dump"  2>&1`
      unless $?.exitstatus == 0
        puts "dumping the database on the remote server failed, #{outs}"
        $?.exitstatus
      else
        puts "the db has been dumped on the server"
        dumpfile = outs.split(/\s/).last
        filename = dumpfile.split('/').last
        target_dir = Rails.root.join 'tmp'
        filename_path = "#{target_dir}/#{filename}"
        stdouts = `scp madek-personas@madek-server:#{dumpfile} #{filename_path} 2>&1`
        unless $?.exitstatus == 0
          puts "copying the dump from the remote machine failed, #{outs}"
          $?.exitstatus
        else
          puts "the db has been fetched into #{filename_path}"
          DBHelper.terminate_open_connections Rails.configuration.database_configuration[Rails.env]
          Rake::Task["db:drop"].invoke
          puts "creating the db"  
          Rake::Task["db:create"].invoke
          puts "restoring data"
          DBHelper.restore_native filename_path, config: Rails.configuration.database_configuration[Rails.env]
          puts "running the migrations"
          Rake::Task["db:migrate"].invoke
          0
        end
      end
    end

    desc "Fetch the current dump of the personas db(Postgres only)" 
    task :fetch_personas do
      outs = `ssh madek-personas@madek-server.zhdk.ch "cd current;RAILS_ENV=production bundle exec rake madek:db:dump" 2>&1`
      unless $?.exitstatus == 0
        puts "dumping the database on the remote server failed with #{outs}"
        $?.exitstatus
      else
        dumpfile = outs.split(/\s/).last
        target_file =  Rails.root.join 'db','empty_medienarchiv_instance_with_personas.pgsql.gz'
        outs = `scp madek-personas@madek-server.zhdk.ch:#{dumpfile} #{target_file} 2>&1`
        unless $?.exitstatus == 0
          puts "copying the dump from the remote machine failed"
          $?.exitstatus
        else
          puts "the db has been fetched into #{target_file}"
          0
        end
      end
    end

  end
end
