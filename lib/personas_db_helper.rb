require 'rake'

module PersonasDBHelper
  class << self

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def current_db_version
      ActiveRecord::Migrator.current_version
    end

    def path_to_current_version
      Rails.root.join('tmp',"#{base_file_name}_#{current_db_version}.#{DBHelper.file_extension}")
    end

    def base_file_name
      'empty_medienarchiv_instance_with_personas'
    end

    def create_current_version config = Rails.configuration.database_configuration[Rails.env]
      DBHelper.restore_native \
        Rails.root.join('db',"#{base_file_name}.#{DBHelper.file_extension}"), config
      system 'bundle exec rake db:migrate'
      DBHelper.dump_native path:  path_to_current_version, config: config
    end

  end
end
