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

    def max_migration
      ActiveRecord::Migrator.migrations(ActiveRecord::Migrator.migrations_path).map(&:version).max
    end

#    def path_to_current_version
#      Rails.root.join('tmp',"#{base_file_name}_#{current_db_version}.#{DBHelper.file_extension}")
#    end

    def path_to_max_migration
      Rails.root.join('tmp',"#{base_file_name}_#{max_migration}.#{DBHelper.file_extension}")
    end

    def create_max_migration config = Rails.configuration.database_configuration[Rails.env]
      DBHelper.restore_native \
        Rails.root.join('db',"#{base_file_name}.#{DBHelper.file_extension}"), config
      system 'bundle exec rake db:migrate'
      DBHelper.dump_native path:  path_to_max_migration, config: config
    end

  end
end
