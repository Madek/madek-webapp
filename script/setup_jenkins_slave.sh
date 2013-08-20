#!/bin/bash

################################################################
# Notes
# 
# This is a jenkins setup script for Debian wheezy, Ubuntu 12.04
# and madek.
# This script is idempotent and it must be kept this way! 
# 
# example of invocation (as root):
#
# curl https://raw.github.com/zhdk/madek/next/script/setup_jenkins_slave.sh | bash -l
#
################################################################



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
# Adapt to our environment
#############################################################
apt-get install --assume-yes lsb_release
if [ `lsb_release -is` == "Debian" ] 
then MOZILLA_BROWSER=iceweasel
else MOZILLA_BROWSER=firefox
fi

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
# upgrade and install basic stuff
#############################################################
apt-get dist-upgrade --assume-yes
apt-get install --assume-yes curl openssh-server openjdk-7-jdk unzip zip


#############################################################
# setup ntp
#############################################################
apt-get install --assume-yes ntp ntpdate
service ntp stop
ntpdate ntp.zhdk.ch
cat << 'EOF' > /etc/ntp.conf
driftfile /var/lib/ntp/ntp.drift
statsdir /var/log/ntpstats/
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server ntp.zhdk.ch
EOF
service ntp start


#############################################################
# ssh server
#############################################################

chmod go-w ~/
mkdir -p ~/.ssh
chmod go-w $HOME $HOME/.ssh

cat << 'EOF' > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA4Dn7DJZ923mketufL52fibawVVwEisSZAaeMA4qt2VYALMd37i8Hx5nP/d9FyCbIfiDj0GRcpLgKSgZrGRwX1UxkOAzYnzDFnY2gm2VjgIwV5Ryf5z4dbCvfxz2i9rpxM8lK2/iTDglxb9z2fBbwC+0WnhbeKy2+UusZjioE49U= rca@nomad ssh-rsa
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxjIL2YhVqNXwDzzubbUuf839VUxo3gbelVqcifJw8EWfmzihDa80VXY6snamHdt3LmSOKc0BXbEVFD3GuehqUi+gjvRl7RE/YgQt9LjOyJAFzZRh+5XbQ+QCYrfdF8NdrlYv6qmGnTK2U0/SiHObc5qWLNVqdCUPY2AVg9/19PjtiaLxd74so1ApzgxzIubzw5WEdxd16pFvlcO6jmewwgjfTNa9hA9U6C9zCtX/KLiESmTpQIYAX9KB8hRbWM9vMmjR8mUymJeJYaEWRSEFlQz0kqYo3PRkLAs8vsuFhZUs5IVFx0Saig9MOgL1x5h/4UAtvGj3M20mG7/3wimtbw== thomas@macbook
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC26PJTohUjHaIMy6srYXywXzlZHsKSV7OhorlSiCjV9MUVX+EbzhCPcqpT0kc7A2VgyCjbvWI6Zi3dD1/ynvODligfMMN3IBsgBL9h9uC/FmcfAmRTPPNaqjiAFBc5n+j7DrFtondrkGdCg39+UUuGmyup6rIbKYbxq2F7mU0qEHLnItPLZAl+sdJGPCRKj3jIed+zRhPSHBkZn8aa2WfEjZO8JpOt66fLAey6SW86rP+z78m9BjsTXs13IPkqBbaU27Ek1nVhPMdX1u3vsK5UIaKb2nSWOESJRUDW8U4JKtf0PDpTbILTNeNoXJkVIMJLvqY1PXRSFszB3/JajGa3 email@sebastianpape.com
EOF

chmod 600 $HOME/.ssh/authorized_keys
chown `whoami` $HOME/.ssh/authorized_keys

#############################################################
# editor
#############################################################
apt-get install --assume-yes vim-nox
update-alternatives --set editor /usr/bin/vim.nox

#############################################################
# PostgreSQL (mostly for Madek)
#############################################################
apt-get install --assume-yes  postgresql postgresql-client libpq-dev postgresql-contrib
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
rm -rf phantomjs-1.9.0-linux-x86_64
curl https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-x86_64.tar.bz2 | tar xj
cp phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/local/bin/
EOF


###########################################################
# iceweasel > 10.0
###########################################################
if [ MOZILLA_BROWSER == "iceweasel" ]
then
        echo "deb http://mozilla.debian.net/ wheezy-backports iceweasel-release" > /etc/apt/sources.list.d/iceweasel.list
        apt-get update
        apt-get install --assume-yes pkg-mozilla-archive-keyring
        gpg --check-sigs --fingerprint --keyring /etc/apt/trusted.gpg.d/pkg-mozilla-archive-keyring.gpg --keyring /usr/share/keyrings/debian-keyring.gpg pkg-mozilla-maintainers
        apt-get install --assume-yes iceweasel
fi


###########################################################
# MariaDB
###########################################################
apt-get remove mysql-client-5.5 mysql-server-5.5 mysql-common
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
echo "# MariaDB 5.5 repository list - created 2013-08-20 09:55 UTC" > /etc/apt/sources.list.d/mariadb.list
echo "# http://mariadb.org/mariadb/repositories/" >> /etc/apt/sources.list.d/mariadb.list
echo "deb http://mirror.netcologne.de/mariadb/repo/5.5/debian wheezy main" >> /etc/apt/sources.list.d/mariadb.list
echo "deb-src http://mirror.netcologne.de/mariadb/repo/5.5/debian wheezy main" >> /etc/apt/sources.list.d/mariadb.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -q --assume-yes mariadb-server
mysql -uroot -e "grant all privileges on *.* to jenkins@localhost identified by 'jenkins';"
apt-get install -q --assume-yes libmariadbclient-dev libmariadbclient18 libmysqlclient18


#############################################################
# chromium
#############################################################

if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
cat << 'EOF' | su -l 
apt-get update
apt-get purge --assume-yes google-chrome-stable
rm /etc/apt/sources.list.d/google.list
apt-get update
apt-get install --assume-yes chromium-browser
EOF
fi

#############################################################
# chromedriver
#############################################################

cat << 'EOF' | su -l 
cd /tmp 
rm -rf chromedriver*
curl https://chromedriver.googlecode.com/files/chromedriver_linux64_26.0.1383.0.zip > chromedriver.zip
unzip chromedriver.zip
mv chromedriver /usr/local/bin
EOF


###########################################################
# prepare rbenv, ruby and ...
###########################################################

apt-get install --assume-yes git x11vnc fluxbox tightvncserver zlib1g-dev \
  libssl-dev libxslt1-dev libxml2-dev build-essential \
  libimage-exiftool-perl imagemagick $MOZILLA_BROWSER libreadline-dev libreadline6 libreadline6-dev \
  g++

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
rbenv install jruby-1.7.3
rbenv shell jruby-1.7.3
gem install bundler
gem update --system
gem install rubygems-update
rbenv rehash
gem install bundler
rbenv rehash

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


###########################################################
# gherkin lexer so we can run it under plain ruby
###########################################################

apt-get install --assume-yes ragel

cat << 'JENKINS' | su -l jenkins
rbenv shell 1.9.3-p392 
gem install gherkin -v 2.12.0
cd ~/.rbenv/versions/1.9.3-p392/lib/ruby/gems/1.9.1/gems/gherkin-2.12.0/ 
bundle install
rbenv rehash
bundle exec rake compile:gherkin_lexer_en
bundle exec rake compile:gherkin_lexer_de
JENKINS



###########################################################
# jenkins login stuff
###########################################################


# ssh
cat << 'JENKINS' | su -l jenkins
chmod go-w ~/
mkdir -p ~/.ssh
chmod go-w $HOME $HOME/.ssh
cat << 'EOF' > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IY6mcbA9qqF5UATdgTCduDeaYFGS2nWYS4EqzsOAMhGzhOPtQ3+qLykX8BmP/JowJppsDSMMY3+Wwb3yss/+7l7uEYIfZzJCgqLjcyAma7sKAeHjl4L7g4sLgjeEdWIyej92nzj2dXmoLOX/HzoasTcuzRMccqjXLVGBqso1yyWTVWkVWXgKrihR1Sg60VhaF6IafWjDwcQlwvvU93Xz3p352tW3q946gWTMVZPNHMn7hgMLwx9FJpDHhvXH0kvBJNRQqbIm1qx0xXx5JSmNGsQD/G1VfPUCRxzAecVgFlxRzQdRCbMfq/7lACby9LazYHv3Z6NJHiqdgwAFwSLF jenkins@ci
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA4Dn7DJZ923mketufL52fibawVVwEisSZAaeMA4qt2VYALMd37i8Hx5nP/d9FyCbIfiDj0GRcpLgKSgZrGRwX1UxkOAzYnzDFnY2gm2VjgIwV5Ryf5z4dbCvfxz2i9rpxM8lK2/iTDglxb9z2fBbwC+0WnhbeKy2+UusZjioE49U= rca@nomad
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxjIL2YhVqNXwDzzubbUuf839VUxo3gbelVqcifJw8EWfmzihDa80VXY6snamHdt3LmSOKc0BXbEVFD3GuehqUi+gjvRl7RE/YgQt9LjOyJAFzZRh+5XbQ+QCYrfdF8NdrlYv6qmGnTK2U0/SiHObc5qWLNVqdCUPY2AVg9/19PjtiaLxd74so1ApzgxzIubzw5WEdxd16pFvlcO6jmewwgjfTNa9hA9U6C9zCtX/KLiESmTpQIYAX9KB8hRbWM9vMmjR8mUymJeJYaEWRSEFlQz0kqYo3PRkLAs8vsuFhZUs5IVFx0Saig9MOgL1x5h/4UAtvGj3M20mG7/3wimtbw== thomas@macbook
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC26PJTohUjHaIMy6srYXywXzlZHsKSV7OhorlSiCjV9MUVX+EbzhCPcqpT0kc7A2VgyCjbvWI6Zi3dD1/ynvODligfMMN3IBsgBL9h9uC/FmcfAmRTPPNaqjiAFBc5n+j7DrFtondrkGdCg39+UUuGmyup6rIbKYbxq2F7mU0qEHLnItPLZAl+sdJGPCRKj3jIed+zRhPSHBkZn8aa2WfEjZO8JpOt66fLAey6SW86rP+z78m9BjsTXs13IPkqBbaU27Ek1nVhPMdX1u3vsK5UIaKb2nSWOESJRUDW8U4JKtf0PDpTbILTNeNoXJkVIMJLvqY1PXRSFszB3/JajGa3 email@sebastianpape.com
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvcfnh09oFzSX0mNVhM7VOSmXKwvTydLSUCpWFnoRvvsO62inEue+rky8FAG1kTsXRaKhaZwKyDJfERbPkxL9jp83rh7CAdEPFwz78bZvdLI/fc653p/1c+X+Lf8pddBIQefZaCUEAaMCdpv2oKLQMYr1W5VLDWkD8090caGm5dcgQ/Av84UNrdmzZ9cvSj0qJHui9aueJNMVNVDxf+bPLJjfwkL5akr60gH7t525KWh8tuutKmHft8Uf7mZJUg5tZ2fkHrdv+QeTqMcTSJhZRZcwR7j3CbwVOB6maYZ+MZcK4mBiuJB133G1CV95XVdiW4X54L+YZaNk0zY5X7WVNw== franco
EOF
chmod 600 $HOME/.ssh/authorized_keys
chown `whoami` $HOME/.ssh/authorized_keys
JENKINS



###########################################################
# install jenkins_cleanup cron script
###########################################################

cat << 'EOF' > /etc/cron.weekly/jenkins_cleanup
#!/bin/bash -l
JENKINS_HOME='/home/jenkins'
echo "CLEANING JENKINS STUFF IN ${JENKINS_HOME}"
mv -f "${JENKINS_HOME}/.ssh/authorized_keys" "${JENKINS_HOME}/.ssh/authorized_keys_tmp"
pkill  -u jenkins
rm -rf "${JENKINS_HOME}/"*xvfb
rm -rf "${JENKINS_HOME}/workspace/"*
mv -f "${JENKINS_HOME}/.ssh/authorized_keys_tmp" "${JENKINS_HOME}/.ssh/authorized_keys"
EOF
chmod a+x /etc/cron.weekly/jenkins_cleanup

# cleanup now, this will also stop and disconnect the slave
/etc/cron.weekly/jenkins_cleanup


