#!/bin/sh

echo "I'm alive!"

echo "Mounting the data..."
sudo mkdir /mnt/tweet_data
sudo mount /dev/vdb1 /mnt/tweet_data
sudo chown ubuntu:ubuntu /mnt/tweet_data

sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing pip..."
sudo apt-get install -y python-pip
sudo -H pip install --upgrade pip
sudo -H pip install numpy

echo "Installing rabbitmq..."
sudo apt-get install -y rabbitmq-server
sudo service rabbitmq-server restart

echo "Configuring rabbitmq..."
sudo rabbitmqctl add_user milo_user milo
sudo rabbitmqctl add_vhost milo_vuser
sudo rabbitmqctl set_user_tags milo_user milotweet
sudo set_permissions -p milo_vuser milo_user ".*" ".*" ".*"

echo "Adding the SSH private key..."
echo "PRIVATE_KEY" > /home/ubuntu/.ssh/id_rsa
echo "PUBLIC KEY" > /home/ubuntu/.ssh/id_rsa.pub

echo "Installing celery..."
sudo -H pip install celery

# echo "Installing flask..."
# sudo -H pip install Flask

echo "Installing django..."
sudo -H pip install django

echo "Installing milo..."
cd /home/ubuntu
sudo git clone https://github.com/mandja96/milo-cloud.git
cd /home/ubuntu/milo-cloud/
sudo git checkout master

echo "Starting celery..."
sudo screen -S celeryserver -d -m bash -c 'celery worker -A milotweet --autoscale=8,1'

echo "Starting django..."
sudo python manage.py migrate
sudo screen -S djangoserver -d -m bash -c 'python manage.py runserver 0:8000'

echo "Initialization complete!"
