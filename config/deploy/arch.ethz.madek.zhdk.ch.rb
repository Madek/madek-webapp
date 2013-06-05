# -*- encoding : utf-8 -*-
#$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3'        # Or whatever env you want it to run in.
set :rvm_type, :system
set :rvm_path, "/usr/local/rvm" 

require "bundler/capistrano"

set :scm, :git
set :repository, "git://github.com/zhdk/madek.git"
load 'config/deploy/stable_version'
set :deploy_via, :remote_cache

# TODO: Move everything from /home/madek/current to /home/arch.ethz.madek.zhdk.ch and use this config here
set :app, "arch.ethz.madek.zhdk.ch"

set :db_config, "/home/#{app}/database.yml"
set :zencoder_config, "/home/#{app}/zencoder.yml"
set :authentication_systems_config, "/home/#{app}/authentication_systems.yml"
set :custom_config_css, "/home/#{app}/_custom_config.css.sass"

set :checkout, :export

set :use_sudo, false
set :rails_env, "production"

set :deploy_to, "/home/#{app}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "arch_ethz@arch.ethz.madek.zhdk.ch"
role :web, "arch_ethz@arch.ethz.madek.zhdk.ch"
role :db,  "arch_ethz@arch.ethz.madek.zhdk.ch", :primary => true

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

  run "ln -sf #{zencoder_config} #{release_path}/config/zencoder.yml"

  run "rm -f #{release_path}/config/authentication_systems.yml"
  run "ln -s #{authentication_systems_config} #{release_path}/config/authentication_systems.yml"

  run "rm -f #{release_path}/app/assets/stylesheets/_custom_config.css.sass"
  run "ln -s #{custom_config_css} #{release_path}/app/assets/stylesheets/_custom_config.css.sass"
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
  run "cp #{release_path}/app/views/application/root-arch.ethz.madek.zhdk.ch.html.erb #{release_path}/app/views/application/root.html.erb"
  run "sed -i 's:ENCODING_TEST_MODE = 1:ENCODING_TEST_MODE = 0:' #{release_path}/config/application.rb"

  new_url = "http://arch.ethz.madek.zhdk.ch".gsub("/","\\/")
  run "sed -i 's,ENCODING_BASE_URL.*,ENCODING_BASE_URL = \"#{new_url}\",' #{release_path}/config/application.rb"
end

task :generate_documentation do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake app:doc:api"
end

task :record_deploy_info do
  deploy_date = DateTime.parse(release_path.split("/").last)
  run "echo 'Deployed on #{deploy_date}' > #{release_path}/app/views/layouts/_deploy_info.erb"
end

task :clear_cache do
  # We have to run it this way (in a subshell) because Rails.cache is not available
  # in Rake tasks, otherwise we could stick a task into lib/tasks/madek.rake
  run "cd #{release_path} && RAILS_ENV=production bundle exec rails runner 'Rails.cache.clear'"
end


before "deploy", "retrieve_db_config"
before "deploy:cold", "retrieve_db_config"
before "deploy:create_symlink", :make_tmp

before "deploy:create_symlink", :link_config
before "deploy:create_symlink", :link_attachments
before "deploy:create_symlink", :configure_environment
before "deploy:create_symlink", :record_deploy_info
#after "deploy:create_symlink", :generate_documentation 

before "migrate_database", :backup_database
after "link_config", :migrate_database
after "link_config", "precompile_assets"
after "migrate_database", :clear_cache

after "deploy", "deploy:cleanup"
