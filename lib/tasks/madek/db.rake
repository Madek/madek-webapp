namespace :madek do
  namespace :db  do

    desc "Truncate all tables, i.e. delete all data (sans schema_migrations)" 
    task :truncate => :environment do
      DBHelper.truncate_tables
    end

    desc "Dump the datadatabse, supply DIR to specify the target dir or FILE to specify the full path"
    task :dump => :environment do
      res = DBHelper.dump config: Rails.configuration.database_configuration[Rails.env], dir: ENV['DIR'], path: ENV['FILE']
      puts "the data has been dumped into #{res[:path]}"
    end


    desc "Dump the data only, without schema and without schema_migrations table, supply DIR to specify the target dir or FILE to specify the full path"
    task :dump_data => :environment do
      res = DBHelper.dump_data config: Rails.configuration.database_configuration[Rails.env], dir: ENV['DIR'], path: ENV['FILE']
      puts "the data has been dumped into #{res[:path]}"
    end


    desc "Load data only, requires FILE environment (e.g. FILE=db/personas.data.pgsql)" 
    task :load_data => :environment do
      raise "FILE must be set" unless File.exist?(ENV['FILE'])
      DBHelper.load_data ENV['FILE'], config: Rails.configuration.database_configuration[Rails.env]
    end

  end
end
