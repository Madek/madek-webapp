load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& domina/bin/create_db_config_file.rb \
&& domina/bin/setup_personas_db.rb 

