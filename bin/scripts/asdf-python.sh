#!/bin/bash

ASDF_HOME=${HOME}/.asdf/shims

# https://github.com/jasodeep/ansible-lamp-stack-playbook/blob/master/lamp-playbook.yml

# [ -z bash -c "test -e /usr/bin/python || (apt -qqy update && apt install -qqy python-minimal)"] && echo "Something goes wrong" || echo " Python was set"

sudo apt install git -y && git clone https://github.com/asdf-vm/asdf.git ~/.asdf
 
cat << 'EOF' | sudo tee -a $HOME/.bashrc >> /dev/null

. "${HOME}/.asdf/asdf.sh"
. "${HOME}/.asdf/completions/asdf.bash"
EOF

source $HOME/.bashrc

sudo  apt -y install \
  curl locate \
  autoconf build-essential bison re2c pkg-config build-essential\
  libxml2-dev openssl libcurl4-openssl-dev libssl-dev \
  libsqlite3-dev  libzip-dev  libgd-dev \
  libonig-dev    libpq-dev \
  gettext libedit-dev libicu-dev \
  libjpeg-dev    libpng-dev   \
  libreadline-dev    \
  zlib1g-dev #\
 # libsslcommon2-dev  clibcurl4-openssl-dev   


 

sudo apt-get --ignore-missing install libmariadb-dev libmysqlclient-dev   # libmariadb-dev-compat


which asdf
# compiling the PHP-7.4 version needs to use the libssl1.1 when compiling the openssl extension:
# see https://github.com/phpbrew/phpbrew/issues/1263

cd $HOME
wget https://www.openssl.org/source/openssl-1.1.1i.tar.gz
tar xzf $HOME/openssl-1.1.1i.tar.gz
cd openssl-1.1.1i
./Configure --prefix=$HOME/openssl-1.1.1i/bin -fPIC -shared linux-x86_64
make -j 8 
make install
export PKG_CONFIG_PATH=$HOME/openssl-1.1.1i/bin/lib/pkgconfig
rm 

asdf plugin add php
sed -i 's+https\:\/\/github.com\/php\/php-src\/archive+https\:\/\/github.com\/php\/php-src\/archive\/refs\/tags+g' /etc/apt/sources.list
asdf install php 7.4.32

php -v
php -i | grep -i openssl

asdf global php 7.4

asdf plugin add mysql
asdf install mysql 5.7.41
asdf global mysql 5.7.41

# install     - apache2     - mysql     - php-fpm

 