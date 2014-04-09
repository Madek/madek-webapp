load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& bundle exec rake db:drop
