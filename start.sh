#!/bin/bash

# Install Chrome
apt-get update
apt-get install -y wget unzip curl
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb

# Install Chromedriver
CHROME_VERSION=$(google-chrome --version | grep -oP "\d+\.\d+\.\d+" | head -1)
wget -N https://chromedriver.storage.googleapis.com/$CHROME_VERSION/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv chromedriver /usr/bin/chromedriver
chmod +x /usr/bin/chromedriver

# Run the app
gunicorn app:app --bind 0.0.0.0:10000
