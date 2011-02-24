# -*- encoding : utf-8 -*-
set :application, "madek"
set :repository,  "http://code.zhdk.ch/svn-auth/madek/trunk"
set :db_config, "/home/rails/madek/ibrowsing/database.yml"
set :checkout, :export


set :use_sudo, false 
set :rails_env, "production"

set :deploy_to, "/home/rails/madek/ibrowsing"


# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "madek@webapp.zhdk.ch"
role :web, "madek@webapp.zhdk.ch"
role :db,  "madek@webapp.zhdk.ch", :primary => true

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
end

task :remove_htaccess do
	# Kill the .htaccess file as we are using mongrel, so this file
	# will only confuse the web server if parsed.
	run "rm #{release_path}/public/.htaccess"
end

task :make_tmp do
	run "mkdir -p #{release_path}/tmp/sessions #{release_path}/tmp/cache"
end


namespace :deploy do
	task :start do
	# we do absolutely nothing here, as we currently aren't
	# using a spinner script or anything of that sort.
	end

	task :restart do
  run "cd #{release_path} && RAILS_ENV='production' rake db:migrate"
	run "pkill -SIGUSR2 -f -u madek -- '-e production.*ibrowsing'"
	end
end

task :link_attachments do
  run "rm -rf #{release_path}/db/media_files/production/attachments"
  run "mkdir -p #{release_path}/db/media_files/production/"
  run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/db/media_files/production/attachments"
end


task :configure_sphinx do
  #run "cd #{release_path} && rake ts:conf"
 run "cp #{release_path}/config/production.sphinx.conf_with_pipe #{release_path}/config/production.sphinx.conf"

 run "sed -i 's/port = 3312/port = 3332/' #{release_path}/config/production.sphinx.conf" 
 run "sed -i 's/port = 3313/port = 3333/' #{release_path}/config/production.sphinx.conf" 
 run "sed -i 's/port = 3314/port = 3334/' #{release_path}/config/production.sphinx.conf" 

 run "sed -i 's/port: 3312/port: 3332/' #{release_path}/config/sphinx.yml" 
 run "sed -i 's/port: 3313/port: 3333/' #{release_path}/config/sphinx.yml" 
 run "sed -i 's/port: 3314/port: 3334/' #{release_path}/config/sphinx.yml" 
end

task :stop_sphinx do
#  run "cd #{previous_release} && RAILS_ENV='production' rake ts:stop"
end

task :start_sphinx do
  run "cd #{release_path} && RAILS_ENV='production' rake ts:reindex"
  run "cd #{release_path} && RAILS_ENV='production' rake ts:start"
end


after "deploy:symlink", :link_config
after "deploy:symlink", :configure_sphinx
after "deploy:symlink", :link_attachments
before "deploy:restart", :make_tmp
before "deploy", :stop_sphinx
after "deploy", :start_sphinx

