# -*- encoding : utf-8 -*-
#$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3'        # Or whatever env you want it to run in.
set :rvm_type, :system


require "bundler/capistrano"

set :application, "madek-readonly"

set :scm, :git
set :repository, "git://github.com/zhdk/madek.git"
set :branch, "redesign"
set :deploy_via, :remote_cache

set :db_config, "/home/rails/madek-readonly/database.yml"
set :ldap_config, "/home/rails/madek-readonly/LDAP.yml"
set :checkout, :export

set :use_sudo, false
set :rails_env, "production"

set :deploy_to, "/home/rails/madek-readonly"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "madek@madek-server.zhdk.ch"
role :web, "madek@madek-server.zhdk.ch"
role :db,  "madek@madek-server.zhdk.ch", :primary => true

load 'config/deploy/recipes/link_attachments'
load 'config/deploy/recipes/retrieve_db_config'
load 'config/deploy/recipes/make_tmp'
load 'config/deploy/recipes/backup_database'
load 'config/deploy/recipes/migrate_database'
load 'config/deploy/recipes/precompile_assets'
load 'config/deploy/recipes/clear_cache'


task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm -f #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{ldap_config} #{release_path}/config/LDAP.yml"
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

  desc "Cleanup older revisions"

end

task :configure_environment do
  run "sed -i 's:EXIFTOOL_PATH = \"/opt/local/bin/exiftool\":EXIFTOOL_PATH = \"/usr/local/bin/exiftool\":' #{release_path}/config/application.rb"

  new_url = "http://readonly.medienarchiv.zhdk.ch".gsub("/","\\/")
  run "sed -i 's,ENCODING_BASE_URL.*,ENCODING_BASE_URL = \"#{new_url}\",' #{release_path}/config/application.rb"
end

task :load_seed_data do
    run "cd #{release_path} && RAILS_ENV='production' bundle exec rake db:seed"
end

task :generate_documentation do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake app:doc:api"
end

task :record_deploy_info do
  deploy_date = DateTime.parse(release_path.split("/").last)
  run "echo 'Deployed on #{deploy_date}' > #{release_path}/app/views/layouts/_deploy_info.erb"
end

before "deploy", "retrieve_db_config"
before "deploy:create_symlink", :make_tmp

after "deploy:create_symlink", :link_config
after "deploy:create_symlink", :link_attachments
after "deploy:create_symlink", :configure_environment
after "deploy:create_symlink", :record_deploy_info

after "link_config", :migrate_database
after "link_config", "precompile_assets"

before "migrate_database", :backup_database
after "migrate_database", :clear_cache
after "migrate_database", :backup_database

after "deploy", "deploy:cleanup"
