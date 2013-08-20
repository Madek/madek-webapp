Before do |scenario|

  ExceptionHelper.log_and_reraise do
    PersonasDBHelper.clone_persona_to_test_db
  end

#  connection = ActiveRecord::Base.connection
#  tables = connection.tables.join(', ')
#  connection.execute "TRUNCATE TABLE #{tables} CASCADE;"
#  connection.execute "COMMIT;"
#
#  config= connection.instance_eval{@config}.stringify_keys
#  ENV['PGHOST']     = config['host']          if config['host']
#  ENV['PGPORT']     = config['port'].to_s     if config['port']
#  ENV['PGPASSWORD'] = config['password'].to_s if config['password']
#  ENV['PGUSER']     = config['username'].to_s if config['username']
#  ENV['PGDATABASE'] = config['database'].to_s if config['database']
#
#  cmd =  %{pg_restore --disable-triggers -d #{config['database']} db/empty_medienarchiv_instance_with_personas.pgbin}
#  `#{cmd}`
#  raise "ERROR executing #{cmd}" if $?.exitstatus != 0
#
end
