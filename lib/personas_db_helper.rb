require 'rake'

module PersonasDBHelper
  class << self

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def base_file_name
      'empty_medienarchiv_instance_with_personas'
    end

    def current_db_version
      ActiveRecord::Migrator.current_version
    end

    def clone_persona_to_test_db
      config = check_for_persona_db_config
      persona_database_name = config['database']
     
      ActiveRecord::Base.connection_pool.disconnect!
      ActiveRecord::Base.establish_connection(config)
      DBHelper.drop(Rails.configuration.database_configuration[Rails.env])
      DBHelper.create(Rails.configuration.database_configuration[Rails.env], {:template => persona_database_name})
      ActiveRecord::Base.connection_pool.disconnect!
      ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration[Rails.env])
    end

    def load_and_migrate_persona_data
      puts "restoring stuff"
      config = check_for_persona_db_config
      DBHelper.restore_native \
        Rails.root.join('db',"#{base_file_name}.#{DBHelper.file_extension}"), {:config => config}
      system("RAILS_ENV=personas bundle exec rake db:migrate")
    end

    def check_for_persona_db_config
      config = Rails.configuration.database_configuration['personas']
      if config.nil? 
        raise "You need to define a 'personas' database section in your database.yml and then load and migrate a current dump using PersonasDBHelper.load_and_migrate_persona_data"
      else
        return config
      end 
    end

  end
end
