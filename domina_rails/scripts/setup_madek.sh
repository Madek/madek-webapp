load_rbenv \
&& rbenv shell ruby-1.9.3 \
&& domina_rails/bin/setup_madek_dirs.rb \
&& domina_rails/bin/create_db_config_file.rb \
&& domina_rails/bin/setup_test_db.rb
