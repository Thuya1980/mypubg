#!/bin/bash

apt-get update && apt-get install -y wget unzip curl

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb

# Get Chrome version and download matching ChromeDriver
CHROME_VERSION=$(google-chrome --version | grep -oP "\d+" | head -1)
CHROMEDRIVER_VERSION=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION)

wget -N https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip
unzip -o chromedriver_linux64.zip
mv -f chromedriver /usr/local/bin/chromedriver
chmod +x /usr/local/bin/chromedriver

# Activate virtual environment and run your app
source .venv/bin/activate
gunicorn app:application --bind 0.0.0.0:10000
