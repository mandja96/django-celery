#!/bin/sh

echo "This slave is alive!"

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

echo "Installing celery..."
sudo -H pip install celery

echo "Installing django..."
sudo -H pip install django

echo "Installing milo..."
cd /home/ubuntu
sudo git clone https://github.com/mandja96/milo-cloud.git
cd /home/ubuntu/milo-cloud/
sudo git checkout master

echo "Setting permission"
sudo chown -R ubuntu.users /home/ubuntu/milo-cloud

echo "Connecting to the main rabbitmq node..."
sudo sed 's/localhost/MASTER_IP/' -i /home/ubuntu/milo-cloud/milotweet/settings.py

echo "Starting celery worker..."
cd /home/ubuntu/milo-cloud/
sleep 5
sudo screen -S celeryserver -d -m bash -c 'sudo -u ubuntu celery worker -A milotweet -l info'

echo "Initialization complete!"
