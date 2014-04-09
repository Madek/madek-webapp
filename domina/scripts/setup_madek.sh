load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& domina/bin/create_db_config_file.rb \
&& RAILS_ENV=test bundle exec rake madek:setup:dirs db:reset 
