#!/usr/bin/env bash

echo 'Start!'

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2

cd /vagrant

sudo apt-get update
sudo apt-get install tree

if ! [ -e /vagrant/mysql-apt-config_0.8.24-1_all.deb ]; then
	wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
fi

sudo dpkg -i mysql-apt-config_0.8.24-1_all.deb
sudo DEBIAN_FRONTEND=noninteractivate apt-get install -y mysql-server
sudo apt-get install -y libmysqlclient-dev

if [ ! -f "/usr/bin/pip" ]; then
  sudo apt-get install -y python3-pip
  sudo apt-get install -y python-setuptools
  sudo ln -s /usr/bin/pip3 /usr/bin/pip
else
  echo "pip3 has already been installed"
fi

pip install --upgrade setuptools
pip install --ignore-installed wrapt

pip install -U pip

pip install -r requirements.txt


sudo mysql -u root << EOF
	ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
	flush privileges;
	show databases;
	CREATE DATABASE IF NOT EXISTS twitter;
EOF

# superuser
USER="admin"
PASS="admin"
MAIL="admin@twitter.com"
script="
from django.contrib.auth.models import User;
username = '$USER';
password = '$PASS';
email = '$MAIL';
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password);
    print('Superuser created.');
else:
    print('Superuser creation skipped.');
"
#printf "$script" | python manage.py shell

echo 'All Done!'
