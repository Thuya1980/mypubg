#!/bin/bash

apt-get update
apt-get install -y wget unzip curl

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb

# Get Chrome major version
CHROME_VERSION=$(google-chrome --version | grep -oP "\d+" | head -1)

# Get matching chromedriver version for that major version
CHROMEDRIVER_VERSION=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION)

# Download chromedriver
wget -N https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv chromedriver /usr/bin/chromedriver
chmod +x /usr/bin/chromedriver

gunicorn app:app --bind 0.0.0.0:10000
