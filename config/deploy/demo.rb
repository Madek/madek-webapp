# -*- encoding : utf-8 -*-
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3'        # Or whatever env you want it to run in.
set :rvm_type, :system

require "bundler/capistrano"

set :application, "madek"

set :scm, :git
set :repository, "git://github.com/zhdk/madek.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :db_config, "/home/rails/madek-demo/database.yml"
set :ldap_config, "/home/rails/madek-demo/LDAP.yml"
set :zencoder_config, "/home/rails/madek-demo/zencoder.yml"
set :checkout, :export

set :use_sudo, false
set :rails_env, "production"

set :deploy_to, "/home/rails/madek-demo"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "madek-demo@madek-server.zhdk.ch"
role :web, "madek-demo@madek-server.zhdk.ch"
role :db,  "madek-demo@madek-server.zhdk.ch", :primary => true

load 'config/deploy/recipes/link_attachments'
load 'config/deploy/recipes/retrieve_db_config'
load 'config/deploy/recipes/make_tmp'
load 'config/deploy/recipes/backup_database'
load 'config/deploy/recipes/migrate_database'
load 'config/deploy/recipes/precompile_assets'
load 'config/deploy/recipes/clear_cache'

task :link_config do
  run "rm -f #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{ldap_config} #{release_path}/config/LDAP.yml"

  run "rm -f #{release_path}/config/zencoder.yml"
  run "ln -s #{zencoder_config} #{release_path}/config/zencoder.yml"
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

task :configure_environment do
  run "sed -i 's:EXIFTOOL_PATH = \"/opt/local/bin/exiftool\":EXIFTOOL_PATH = \"/usr/local/bin/exiftool\":' #{release_path}/config/application.rb"
  run "sed -i 's,ENCODING_BASE_URL.*,ENCODING_BASE_URL = \"http://demo.medienarchiv.zhdk.ch\",'  #{release_path}/config/application.rb"

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
