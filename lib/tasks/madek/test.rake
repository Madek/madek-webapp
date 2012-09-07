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

    task :setup do
      # Rake seems to be very stubborn about where it takes
      # the RAILS_ENV from, so let's set a lot of options (?)
      Rails.env = 'test'
      task :environment
      # The rspec part of this whole story gets tested against an empty database, so nothing
      # to import from a file here. Instead, we reset based on our migrations.
      Rake::Task["madek:reset"].invoke
      File.delete("tmp/rerun.txt") if File.exists?("tmp/rerun.txt")
      File.delete("tmp/rerun_again.txt") if File.exists?("tmp/rerun_again.txt")
      PersonasDBHelper.load_and_migrate_persona_data
    end

    task :rspec do
      system "bundle exec rspec --format d --format html --out tmp/html/rspec.html spec"
      exit_code = $?.exitstatus
      raise "Tests failed with: #{exit_code}" if exit_code != 0
    end

    namespace :cucumber do

      task :all do
        puts "Running all Cucumber tests in one block"
        system "bundle exec cucumber -p all"
        exit_code_first_run = $?.exitstatus
        puts "First run exited with #{exit_code_first_run}"

        if exit_code_first_run != 0
          Rake::Task["madek:test:cucumber:rerun"].invoke
        end
      end

      task :rerun do
          system "bundle exec cucumber -p rerun"
          exit_code_rerun = $?.exitstatus
          puts "Rerun exited with #{exit_code_rerun}"
          raise "Tests failed during rerun!" if exit_code_rerun != 0
      end
    end
    
  end

end

