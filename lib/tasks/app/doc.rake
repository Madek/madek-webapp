namespace :app do

########## DOC
  
  desc "Create a manifest of the living documentation by using YARD"
  task :doc do
    puts "Create app-documentation in /doc/yard"
      
      commands = []
      commands << "rm -r ./doc/yard"
      commands << "bundle exec yardoc --output-dir ./doc/yard"
      commands << "rm -r ./doc/api/yard"
      commands << "bundle exec yardoc --plugin rest --title 'MAdeK API' --readme './doc/README_FOR_API' --output-dir ./public/api"

      commands.each do |command|
        puts command
        Open3.popen3(command) do |i,o,e,t|
          puts o.read.chomp
        end
      end

    puts "DONE"
  end
  
  namespace :doc do
    
    ########## API
    
    desc "Publish living documentation (only for the API) by using YARD"
    task :api do
       puts "Publish api-documentation to /public/api"
        
        commands = []
        commands << "rm -r ./public/api"
        commands << "bundle exec yardoc --plugin rest --title 'MAdeK API' --readme './doc/README_FOR_API' --output-dir ./public/api"
        
        commands.each do |command|
          puts command
          Open3.popen3(command) do |i,o,e,t|
            puts o.read.chomp
          end
        end
  
        puts "DONE"
    end

  end
  
end
