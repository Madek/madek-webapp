require 'pg_db_tasks'

namespace :db do

  namespace :pg do

    task truncate_tables: [:environment, :load_config] do
      PgDbTasks.truncate_tables
    end

    namespace :data do

      task dump: [:environment, :load_config] do
        PgDbTasks.data_dump ENV['FILE']
      end

      task restore: [:environment, :load_config] do
        PgDbTasks.data_restore ENV['FILE']
      end

    end

    namespace :structure_and_data do

      task dump: [:environment, :load_config] do
        PgDbTasks.structure_and_data_dump ENV['FILE']
      end

      task restore: [:environment, :load_config] do
        PgDbTasks.structure_and_data_restore ENV['FILE']
      end

    end

  end

end
