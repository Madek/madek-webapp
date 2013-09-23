load_rbenv \
&& rbenv shell ruby-1.9.3 \
&& domina/bin/create_db_config_file.rb \
&& domina/bin/setup_personas_db.rb 


