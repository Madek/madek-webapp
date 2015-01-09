require 'active_record/tasks/database_tasks'
require 'active_record/tasks/postgresql_database_tasks'

module PgDbTasks

  DEFAULT_BINARY_DATA_FILE_NAME = 'data.pgbin'
  DEFAULT_BINARY_STRUCTURE_AND_DATA_FILE_NAME = 'structure_and_data.pgbin'

  class << self

    def reload!
      load Rails.root.join(__FILE__)
    end

    %w(data_dump data_restore).each do |method_name|
      define_method method_name  do |filename = nil|
        ActiveRecord::Tasks::DatabaseTasks \
          .perform_pg_db_task_for_config_and_filename \
          method_name,  current_config,
          filename_or_default_binary_data_file(filename)
      end
    end

    %w(structure_and_data_dump structure_and_data_restore).each do |method_name|
      define_method method_name  do |filename = nil|
      ActiveRecord::Tasks::DatabaseTasks \
        .perform_pg_db_task_for_config_and_filename \
        method_name, current_config,
        filename_or_default_binary_structure_and_data_file(filename)
      end
    end

    def truncate_tables
      ActiveRecord::Base.connection.tap do |connection|
        connection.tables.reject { |tn| tn == 'schema_migrations' }
        .join(', ').tap do |tables|
          connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
        end
      end
    end

    private

    def current_config
      ActiveRecord::Tasks::DatabaseTasks.current_config
    end

    def filename_or_default_binary_data_file(filename)
      (filename.present? && filename) || \
        File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir,
                  DEFAULT_BINARY_DATA_FILE_NAME)
    end

    def filename_or_default_binary_structure_and_data_file(filename)
      (filename.present? && filename) || \
        File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir,
                  DEFAULT_BINARY_STRUCTURE_AND_DATA_FILE_NAME)
    end

  end
end

module ActiveRecord
  module Tasks
    class PostgreSQLDatabaseTasks

      def data_dump(filename)
        set_psql_env
        command = 'pg_dump -F c -a -T schema_migrations -x -O -f ' \
          "#{Shellwords.escape(filename)} " \
          "#{Shellwords.escape(configuration['database'])}"
        raise 'Error during data_dump' unless Kernel.system(command)
        $stdout.puts "The data of '#{configuration['database']} " \
          "has been dumped to '#{filename}'"
      end

      def data_restore(filename)
        set_psql_env
        command = 'pg_restore --disable-triggers -a -x -O -d ' \
          "#{Shellwords.escape(configuration['database'])} " \
          "#{Shellwords.escape(filename)}"
        raise 'Error during data_restore ' unless Kernel.system(command)
        $stdout.puts "Data from '#{filename}' has been restored to \
                        '#{configuration['database']}'"
      end

      def structure_and_data_dump(filename)
        set_psql_env
        command = "pg_dump -F c -x -O -f \
        #{Shellwords.escape(filename)} \
        #{Shellwords.escape(configuration['database'])}"
        unless Kernel.system(command)
          raise 'Error during structure_and_data_dump'
        else
          $stdout.puts 'Structure and data of ' \
            "'#{configuration['database']}' has been dumped to '#{filename}'"
        end
      end

      def structure_and_data_restore(filename)
        set_psql_env
        command = 'pg_restore --disable-triggers -x -O -d ' \
          "#{Shellwords.escape(configuration['database'])} " \
          "#{Shellwords.escape(filename)}"
        unless Kernel.system(command)
          raise 'Error during structure_and_data_restore '
        else
          $stdout.puts "Structure and data of '#{configuration['database']}' " \
            "has been restored to '#{filename}'"
        end
      end

    end
  end
end

module ActiveRecord
  module Tasks
    module DatabaseTasks

      def perform_pg_db_task_for_config_and_filename(task_name, *arguments)
        configuration = arguments.first
        filename = arguments.delete_at 1
        class_for_adapter(configuration['adapter']) \
          .new(*arguments).send task_name, filename
      rescue ActiveRecord::NoDatabaseError
        $stderr.puts "Database '#{configuration['database']}' does not exist"
      rescue Exception => error
        $stderr.puts error, *(error.backtrace)
      end

    end
  end
end
