task :backup_database do
  # Produce a string like 2010-07-15T09-16-35+02-00
  date_string = DateTime.now.to_s.gsub(":","-")
  dump_dir = "#{deploy_to}/#{shared_dir}/db_backups"
  dump_path =  "#{dump_dir}/#{sql_database}-#{date_string}.sql"
  run "mkdir -p #{dump_dir}"
  # If pg_dump fails for any reason, Capistrano will stop here
  # because run catches the exit code of mysqldump
  #run "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"

  # We're supposed to go through the UNIX socket
  if sql_host.nil? or sql_host == ""
    run "pg_dump -w -U #{sql_username} -f #{dump_path} #{sql_database}"
  # We're supposed to go through TCP. Make sure to provide a .pgpass file on the target host for this to work!
  else
    run "PGPASSWORD=#{sql_password} pg_dump -w -h #{sql_host} -U #{sql_username} -f #{dump_path} #{sql_database}"
  end
  run "bzip2 #{dump_path}"
end
