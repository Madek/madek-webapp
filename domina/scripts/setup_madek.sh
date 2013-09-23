load_rbenv \
&& rbenv shell ruby-1.9.3 \
&& domina/bin/setup_madek_dirs.rb \
&& domina/bin/create_db_config_file.rb \
&& domina/bin/setup_test_db.rb
