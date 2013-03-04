#!/bin/bash

#############################################################
# remove the halfwitted stuff
#############################################################
rm -rf /etc/profile.d/rvm.sh 
rm -rf /usr/local/rvm/

#############################################################
# update
#############################################################
apt-get update

#############################################################
# fix broken debian/ubuntu locale
#############################################################

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
apt-get install --assume-yes locales
dpkg-reconfigure locales

cat << 'EOF' > /etc/profile.d/locale.sh 
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF


#############################################################
# upgrade and install 
#############################################################
apt-get dist-upgrade --assume-yes
apt-get install --assume-yes openssh-server openjdk-7-jdk


#############################################################
# ssh server
#############################################################

chmod go-w ~/
mkdir -p ~/.ssh
chmod go-w $HOME $HOME/.ssh

cat << 'EOF' > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA4Dn7DJZ923mketufL52fibawVVwEisSZAaeMA4qt2VYALMd37i8Hx5nP/d9FyCbIfiDj0GRcpLgKSgZrGRwX1UxkOAzYnzDFnY2gm2VjgIwV5Ryf5z4dbCvfxz2i9rpxM8lK2/iTDglxb9z2fBbwC+0WnhbeKy2+UusZjioE49U= rca@nomad ssh-rsa
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxjIL2YhVqNXwDzzubbUuf839VUxo3gbelVqcifJw8EWfmzihDa80VXY6snamHdt3LmSOKc0BXbEVFD3GuehqUi+gjvRl7RE/YgQt9LjOyJAFzZRh+5XbQ+QCYrfdF8NdrlYv6qmGnTK2U0/SiHObc5qWLNVqdCUPY2AVg9/19PjtiaLxd74so1ApzgxzIubzw5WEdxd16pFvlcO6jmewwgjfTNa9hA9U6C9zCtX/KLiESmTpQIYAX9KB8hRbWM9vMmjR8mUymJeJYaEWRSEFlQz0kqYo3PRkLAs8vsuFhZUs5IVFx0Saig9MOgL1x5h/4UAtvGj3M20mG7/3wimtbw== thomas@macbook
EOF

chmod 600 $HOME/.ssh/authorized_keys
chown `whoami` $HOME/.ssh/authorized_keys

#############################################################
# editor
#############################################################
apt-get install --assume-yes vim-nox
update-alternatives --set editor /usr/bin/vim.nox



#############################################################
# postgresql
#############################################################
apt-get install --assume-yes  postgresql postgresql-client libpq-dev
sed -i 's/peer/trust/g' /etc/postgresql/9.1/main/pg_hba.conf
sed -i 's/md5/trust/g' /etc/postgresql/9.1/main/pg_hba.conf
/etc/init.d/postgresql restart

cat << 'EOF' | psql -U postgres
CREATE USER JENKINS PASSWORD 'jenkins' superuser createdb login;
CREATE DATABASE jenkins;
GRANT ALL ON DATABASE jenkins TO jenkins;
EOF


###########################################################
# phantomjs 1.7
###########################################################

cat << 'EOF' | su -l 
cd /tmp 
rm -rf phantomjs-1.7.0-linux-x86_64
curl http://phantomjs.googlecode.com/files/phantomjs-1.7.0-linux-x86_64.tar.bz2 | tar xj
cp phantomjs-1.7.0-linux-x86_64/bin/phantomjs /usr/local/bin/
EOF


#############################################################
# google chrome
#############################################################

cat << 'EOF' | su -l 
curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
apt-get update
apt-get install --assume-yes google-chrome-stable
EOF


#############################################################
# chromedriver
#############################################################

cat << 'EOF' | su -l 
cd /tmp 
rm -rf chromedriver*
curl http://chromedriver.googlecode.com/files/chromedriver_linux64_23.0.1240.0.zip > chromedriver.zip
unzip chromedriver.zip
mv chromedriver /usr/local/bin
EOF


###########################################################
# prepare rbenv, ruby and ...
###########################################################

apt-get install --assume-yes curl git x11vnc xvfb zlib1g-dev libssl-dev libxslt1-dev libxml2-dev build-essential libimage-exiftool-perl imagemagick firefox libreadline-dev libreadline6 libreadline6-dev

cat << 'EOF' > /etc/profile.d/rbenv.sh
# rbenv
if [ -d $HOME/.rbenv ]; then
function load_rbenv {
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"
}
function unload_rbenv(){
export PATH=`ruby -e "puts ENV['PATH'].split(':').reject{|s| s.match(/\.rbenv/)}.join(':')"`
}
load_rbenv
fi
EOF


###########################################################
# jenkins user and rbenv rubies
###########################################################

useradd --create-home -s /bin/bash jenkins

cat << 'JENKINS' | su -l jenkins
curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
rbenv update
JENKINS

cat << 'JENKINS' | su -l jenkins
rbenv install 1.9.3-p392 
rbenv global 1.9.3-p392 
rbenv rehash
gem update --system
gem install rubygems-update
rbenv rehash
update_rubygems
gem install bundler
rbenv rehash
JENKINS

# ssh
cat << 'JENKINS' | su -l jenkins
chmod go-w ~/
mkdir -p ~/.ssh
chmod go-w $HOME $HOME/.ssh
cat << 'EOF' > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IY6mcbA9qqF5UATdgTCduDeaYFGS2nWYS4EqzsOAMhGzhOPtQ3+qLykX8BmP/JowJppsDSMMY3+Wwb3yss/+7l7uEYIfZzJCgqLjcyAma7sKAeHjl4L7g4sLgjeEdWIyej92nzj2dXmoLOX/HzoasTcuzRMccqjXLVGBqso1yyWTVWkVWXgKrihR1Sg60VhaF6IafWjDwcQlwvvU93Xz3p352tW3q946gWTMVZPNHMn7hgMLwx9FJpDHhvXH0kvBJNRQqbIm1qx0xXx5JSmNGsQD/G1VfPUCRxzAecVgFlxRzQdRCbMfq/7lACby9LazYHv3Z6NJHiqdgwAFwSLF jenkins@ci
EOF
chmod 600 $HOME/.ssh/authorized_keys
chown `whoami` $HOME/.ssh/authorized_keys
JENKINS


