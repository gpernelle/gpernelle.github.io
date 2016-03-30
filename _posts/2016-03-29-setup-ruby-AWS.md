---
layout:     post
title:      How to set up a Ruby server on AWS
date:       2016-03-29
summary:    Summary of installation steps to configure a ruby server on AWS
categories: blog
---

This tutorial summarize important steps to setup a `Ruby on Rails` server on Amazon AWS EC2, running passenger, postgreSQL, 
redis

## First create an instance from the AWS console and ssh into it.

## Install essential packages and create website directy

```bash
sudo yum update
sudo yum groupinstall "Development Tools"
sudo yum install -y gcc openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
```

If you need postgresql

```
sudo yum install postgresql postgresql-server postgresql-devel postgresql-contrib postgresql-docs
```

Create directory where we are going to clone our website

```bash
mkdir git-repos
cd git-repos/
```

Install rbenv to manage ruby version

```bash
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
```

Install ruby build

```bash
 git clone https://github.com/sstephenson/ruby-build.git
 cd ruby-build
 sudo ./install.sh
 ```
 
 Install rbenv plugin rbenv-sudo
 
 ```bash
 mkdir ~/.rbenv/plugins
 git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo
```

Install ruby

```
cd ~
exec $SHELL -l
source ~/.bashrc
rbenv install 2.2.0
rbenv global 2.2.0  # set up this version globally
```

Configure ssh access to bitbucket or github

```
ssh-keygen
cat ~/.ssh/id_rsa.pub
cd ~/git-repos/
git clone git@bitbucket.org:yourusername/yourgitrepo.git
cd yourrgitrepo
```

Install gems

```
rbenv rehash
gem install bundler
bundle install
source ~/.bashrc
```

### Install PostgreSQL (if necessar)

```
gem install pg
```

Init and configure DB

```
sudo service postgresql initdb
sudo vim /var/lib/pgsql9/data/pg_hba.conf
```

What you should see:
```
local   all             all                                     trust
```

Add pg user

```
sudo service postgresql status
sudo service postgresql start
sudo su - postgres
```

Creat user in postgresSQL

```sql
createuser ec2-user --superuser -W
```

Edit you config/database.yml (if necessayr)

```vim
vim config/database.yml
```

It should be something similar

```yaml
development:
  adapter: postgresql
  database: yourwebsite_development
  pool: 5
  template: template0
  username: ec2-user
  password: 

production:
  adapter: postgresql
  database: yourwebsite_production
  pool: 5
  template: template0
  username: ec2-user
  password: 

test:
  adapter: postgresql
  database: yourwebsite_test
  pool: 5
  template: template0
  username: ec2-user
password:
```

Create the databases

```bash
rake db:create:all
rake db:schema:load
rake db:migrate
```

Verify it worked by launching rails console

```
rails c
```

### Install redis

Create a redis installation script:

```bash
cd ~
vim install-redis.sh
```

And copy the following script

```bash
# chmod 777 install-redis.sh
# ./install-redis.sh
###############################################
echo "*****************************************"
echo " 1. Prerequisites: Install updates, set time zones, install GCC and make"
echo "*****************************************"
sudo yum -y update
#sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles \/etc/localtime
sudo yum -y install gcc gcc-c++ make
echo "*****************************************"
echo " 2. Download, Untar and Make Redis stable"
echo "*****************************************"
cd /usr/local/src
sudo wget http://download.redis.io/redis-stable.tar.gz
sudo tar xzf redis-stable.tar.gz
sudo rm redis-stable.tar.gz -f
cd redis-stable
sudo make distclean
sudo make
echo "*****************************************"
echo " 3. Create Directories and Copy Redis Files"
echo "*****************************************"
sudo mkdir /etc/redis /var/lib/redis
sudo cp src/redis-server src/redis-cli /usr/local/bin
echo "*****************************************"
echo " 4. Configure Redis.Conf"
echo "*****************************************"
echo " Edit redis.conf as follows:"
echo " 1: ... daemonize yes"
echo " 2: ... bind 127.0.0.1"
echo " 3: ... dir /var/lib/redis"
echo " 4: ... loglevel notice"
echo " 5: ... logfile /var/log/redis.log"
echo "*****************************************"
sudo sed -e "s/^daemonize no$/daemonize yes/" -e "s/^# bind 127.0.0.1$/bind 127.0.0.1/" -e "s/^dir \.\//dir \/var\/lib\/redis\//" -e "s/^loglevel verbose$/loglevel notice/" -e "s/^logfile stdout$/logfile \/var\/log\/redis.log/" redis.conf | sudo tee /etc/redis/redis.conf
echo "*****************************************"
echo " 5. Download init Script"
echo "*****************************************"
sudo wget https://raw.github.com/saxenap/install-redis-amazon-linux-centos/master/redis-server
echo "*****************************************"
echo " 6. Move and Configure Redis-Server"
echo "*****************************************"
sudo mv redis-server /etc/init.d
sudo chmod 755 /etc/init.d/redis-server
echo "*****************************************"
echo " 7. Auto-Enable Redis-Server"
echo "*****************************************"
sudo chkconfig --add redis-server
sudo chkconfig --level 345 redis-server on
echo "*****************************************"
echo " 8. Start Redis Server"
echo "*****************************************"
sudo service redis-server start
echo "*****************************************"
echo " Complete!"
echo " You can test your redis installation using the redis console:"
echo "   $ /usr/local/redis-2.6.16/src/redis-cli"
echo "   redis> set foo bar"
echo "   OK"
echo "   redis> get foo"
echo "   bar"
echo "*****************************************"
read -p "Press [Enter] to continue..."
```

Then perform the installation

```
sudo sh install-redis.sh
```

### Install passenger

```bash
cd ~/git-repos/yourwebsite
```

```
gem install passenger
rbenv sudo passenger start -p80 &
```

### It's online!

With passenger start, you should be able to visit your website by entering the public DNS address given by amazon (on the EC2 
instance interface).