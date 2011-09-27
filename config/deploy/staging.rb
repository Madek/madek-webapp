# -*- encoding : utf-8 -*-

# Don't switch to 1.9.2 until we're 100% ready
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.
require "bundler/capistrano"

set :application, "madek"

set :scm, :git
set :repository, "git://github.com/psy-q/madek.git"
set :branch, "next"
set :deploy_via, :remote_cache

set :db_config, "/home/rails/madek-test/database.yml"
set :ldap_config, "/home/rails/madek-test/LDAP.yml"
set :zencoder_config, "/home/rails/madek-test/zencoder.yml"
set :checkout, :export


set :use_sudo, false 
set :rails_env, "production"

set :deploy_to, "/home/rails/madek-test"

# DB credentials needed by Sphinx, mysqldump etc.
set :sql_database, "rails_madek_dev"
set :sql_host, "db.zhdk.ch"
set :sql_username, "madekdev"
set :sql_password, "m4d_ekkD3f"


# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "madek-test@madek-server.zhdk.ch"
role :web, "madek-test@madek-server.zhdk.ch"
role :db,  "madek-test@madek-server.zhdk.ch", :primary => true

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{ldap_config} #{release_path}/config/LDAP.yml"

  run "rm #{release_path}/config/zencoder.yml"
  run "ln -s #{zencoder_config} #{release_path}/config/zencoder.yml"
end

task :remove_htaccess do
	# Kill the .htaccess file as we are using mongrel, so this file
	# will only confuse the web server if parsed.
	run "rm #{release_path}/public/.htaccess"
end

task :make_tmp do
	run "mkdir -p #{release_path}/tmp/sessions #{release_path}/tmp/cache #{release_path}/tmp/downloads #{release_path}/tmp/zipfiles"
end

namespace :deploy do
	task :start do
	# we do absolutely nothing here, as we currently aren't
	# using a spinner script or anything of that sort.
	end

	task :restart do
    run "touch #{latest_release}/tmp/restart.txt"
	end

end



task :link_attachments do
  run "rm -rf #{release_path}/db/media_files/production/attachments"
  run "rm -rf #{release_path}/doc/Testbilder"
  run "mkdir -p #{release_path}/db/media_files/production/"
  run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/db/media_files/production/attachments"

  run "ln -s #{deploy_to}/#{shared_dir}/uploads #{release_path}/tmp/uploads"
end

task :link_sphinx do
  run "rm -rf #{release_path}/db/sphinx"
  run "ln -s #{deploy_to}/#{shared_dir}/db/sphinx #{release_path}/db/sphinx"
end

task :configure_environment do
  run "sed -i 's:DOT_PATH = \"/usr/local/bin/dot\":DOT_PATH = \"/usr/bin/dot\":' #{release_path}/config/application.rb"
  run "sed -i 's:EXIFTOOL_PATH = \"/opt/local/bin/exiftool\":EXIFTOOL_PATH = \"/usr/local/bin/exiftool\":' #{release_path}/config/application.rb"
  run "sed -i 's,ENCODING_BASE_URL.*,ENCODING_BASE_URL = \"http://test:MAdeK@test.madek.zhdk.ch\",'  #{release_path}/config/application.rb"

end

task :configure_sphinx do
  #run "cd #{release_path} && bundle exec rake ts:conf"
 run "cp #{release_path}/config/production.sphinx.conf_with_pipe #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/listen = 127.0.0.1:3312/listen = 127.0.0.1:3322/' #{release_path}/config/production.sphinx.conf" 
 run "sed -i 's/listen = 127.0.0.1:3313/listen = 127.0.0.1:3323/' #{release_path}/config/production.sphinx.conf" 
 run "sed -i 's/listen = 127.0.0.1:3314/listen = 127.0.0.1:3324/' #{release_path}/config/production.sphinx.conf" 

 run "sed -i 's/sql_host =.*/sql_host = #{sql_host}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_user =.*/sql_user = #{sql_username}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_pass =.*/sql_pass = #{sql_password}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_db =.*/sql_db = #{sql_database}/' #{release_path}/config/production.sphinx.conf"
 run "sed -i 's/sql_sock.*//' #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/port: 3312/port: 3322/' #{release_path}/config/sphinx.yml" 
 run "sed -i 's/port: 3313/port: 3323/' #{release_path}/config/sphinx.yml" 
 run "sed -i 's/port: 3314/port: 3324/' #{release_path}/config/sphinx.yml" 
 
 run "chmod -w #{release_path}/config/production.sphinx.conf"
 
end


task :migrate_database do
  # Produce a string like 2010-07-15T09-16-35+02-00
  date_string = DateTime.now.to_s.gsub(":","-")
  dump_dir = "#{deploy_to}/#{shared_dir}/db_backups"
  dump_path =  "#{dump_dir}/#{sql_database}-#{date_string}.sql"
  run "mkdir -p #{dump_dir}"
  # If mysqldump fails for any reason, Capistrano will stop here
  # because run catches the exit code of mysqldump
  run "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"
  run "bzip2 #{dump_path}"

  # Migration here 
  # deploy.migrate should work, but is buggy and is run in the _previous_ release's
  # directory, thus never runs anything? Strange.
  #deploy.migrate
  run "cd #{release_path} && RAILS_ENV='production'  bundle exec rake db:migrate"

end

task :load_seed_data do
  run "cd #{release_path} && RAILS_ENV='production'  bundle exec rake db:seed"
end

task :stop_sphinx do
 run "cd #{previous_release} && RAILS_ENV='production'  bundle exec rake ts:stop"
end

task :start_sphinx do
  run "cd #{release_path} && RAILS_ENV='production'  bundle exec rake ts:reindex"
  run "cd #{release_path} && RAILS_ENV='production'  bundle exec rake ts:start"
end

task :record_deploy_info do 
  deploy_date = DateTime.parse(release_path.split("/").last) 
  run "echo 'Deployed on #{deploy_date}' > #{release_path}/app/views/layouts/_deploy_info.erb" 
end 

task :clear_cache do
  # We have to run it this way (in a subshell) because Rails.cache is not available
  # in Rake tasks, otherwise we could stick a task into lib/tasks/madek.bundle exec rake
  run "cd #{release_path} && RAILS_ENV=production  bundle exec rails runner 'Rails.cache.clear'"
end

before "deploy:symlink", :make_tmp
after "deploy:symlink", :link_config
before "configure_sphinx", :link_sphinx
after "link_sphinx", :stop_sphinx
after "deploy:symlink", :configure_sphinx
after "deploy:symlink", :configure_environment
after "deploy:symlink", :link_attachments
after "deploy:symlink", :migrate_database
after "deploy:symlink", :record_deploy_info 
after "migrate_database", :clear_cache
after "migrate_database", :stop_sphinx
after "deploy", :start_sphinx
after "deploy", "deploy:cleanup"
