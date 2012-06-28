namespace :madek do

  namespace :test do
    task :run_all do
      Rake::Task["madek:test:setup"].invoke
      Rake::Task["madek:test:rspec"].invoke
      Rake::Task["madek:test:cucumber:all"].invoke
    end

    task :run_separate do
      Rake::Task["madek:test:setup"].invoke
      Rake::Task["madek:test:rspec"].invoke
      Rake::Task["madek:test:cucumber:separate"].invoke
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
    end

    task :rspec do
      system "bundle exec rspec --format d --format html --out tmp/html/rspec.html spec"
      exit_code = $? >> 8 # magic brainfuck
      raise "Tests failed with: #{exit_code}" if exit_code != 0
    end

    namespace :cucumber do

      task :all do
        puts "Running all Cucumber tests in one block"
        system "bundle exec cucumber -p all"
        exit_code_first_run = $? >> 8 # magic brainfuck

        system "bundle exec cucumber -p rerun"
        exit_code_rerun = $? >> 8

        system "bundle exec cucumber -p rerun_again"
        exit_code_rerun_again = $? >> 8

        raise "Tests failed!" if exit_code_rerun_again != 0
      end

      task :slow do
        puts "Running Cucumber tests marked as @slow"
        system "bundle exec cucumber -p slow"
        exit_code = $? >> 8 # magic brainfuck

        raise "Tests failed!" if exit_code != 0
      end

      task :seperate do
        puts "Running 'default' Cucumber profile"
        system "bundle exec cucumber -p default"

        puts "Running 'examples' Cucumber profile"
        system "bundle exec cucumber -p examples"

        puts "Running 'current_examples' Cucumber profile"
        system "bundle exec cucumber -p current_examples"

        system "bundle exec cucumber -p rerun"
        exit_code_rerun = $? >> 8

        if File.exists?("tmp/rerun_again.txt")
          system "bundle exec cucumber -p rerun_again"
          exit_code_rerun = $? >> 8
        end

        raise "Tests failed with: #{exit_code}" if exit_code_rerun != 0

      end
    end
    
  end

end

