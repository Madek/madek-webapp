export RAILS_ENV=test
export DISPLAY=":$XVNC_PORT"
export PGPIDNAME=pid 
mkdir -p tmp/html \
&& load_rbenv  \
&& rbenv shell $RUBY_VERSION

