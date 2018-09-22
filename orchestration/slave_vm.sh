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

echo "Installing milo..."
cd /home/ubuntu
sudo git clone https://github.com/mandja96/milo-cloud.git
cd /home/ubuntu/milo-cloud/
sudo git checkout master

echo "Connecting to the main rabbitmq node..."
sed 's/localhost/MASTER_IP/' -i /home/ubuntu/acc-c3/milotweet/celery.py

echo "Starting celery..."
sudo screen -S celeryserver -d -m bash -c 'celery worker -A milotweet --autoscale=8,1'

echo "Initialization complete!"
