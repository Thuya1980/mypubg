FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg2 \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
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
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Install Chromium browser (close to Chrome)
RUN apt-get update && apt-get install -y chromium-browser && rm -rf /var/lib/apt/lists/*

# Get Chromium version
RUN CHROMIUM_VERSION=$(chromium-browser --version | awk '{print $2}') && \
    echo "Chromium version is $CHROMIUM_VERSION" && \
    CHROMIUM_MAJOR_MINOR_BUILD=$(echo $CHROMIUM_VERSION | cut -d'.' -f1-3) && \
    echo "Major.minor.build: $CHROMIUM_MAJOR_MINOR_BUILD" && \
    DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROMIUM_MAJOR_MINOR_BUILD") && \
    echo "ChromeDriver version: $DRIVER_VERSION" && \
    wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# Set default command to show versions (test)
CMD chromium-browser --version && chromedriver --version
