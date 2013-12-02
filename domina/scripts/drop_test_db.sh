load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& domina/bin/drop_test_db.rb
