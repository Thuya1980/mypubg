FROM ubuntu:22.04

# Install dependencies for Chrome + ChromeDriver + wget + unzip
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome 114.x (Latest stable 114 version)
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.90-1_amd64.deb && \
    apt-get update && apt-get install -y /tmp/google-chrome.deb && \
    rm /tmp/google-chrome.deb && \
    rm -rf /var/lib/apt/lists/*

# Install matching ChromeDriver for Chrome 114.0.5735
RUN CHROME_VERSION="114.0.5735.90" && \
    CHROME_MAJOR_MINOR_BUILD=$(echo $CHROME_VERSION | cut -d '.' -f1-3) && \
    echo "Using Chrome version: $CHROME_VERSION" && \
    echo "Using partial version for driver URL: $CHROME_MAJOR_MINOR_BUILD" && \
    DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_MAJOR_MINOR_BUILD") && \
    echo "Chromedriver version found: $DRIVER_VERSION" && \
    wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# Verify installation (optional)
RUN google-chrome --version && chromedriver --version

# Set Chrome as default (optional, useful for some Selenium setups)
ENV CHROME_BIN=/usr/bin/google-chrome
ENV PATH="/usr/local/bin:${PATH}"
