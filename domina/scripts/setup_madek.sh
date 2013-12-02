load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& domina/bin/setup_madek_dirs.rb \
&& domina/bin/create_db_config_file.rb \
&& domina/bin/setup_test_db.rb
