FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    ca-certificates \
    unzip \
    fonts-liberation \
    libnss3 \
    libx11-6 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libglib2.0-0 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libasound2 \
    lsb-release \
    xdg-utils \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Add Google Chrome official signing key and repo
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Detect Chrome version (major.minor.build) for matching chromedriver version
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}') && \
    echo "Chrome version detected: $CHROME_VERSION" && \
    CHROME_MAJOR_MINOR_BUILD=$(echo $CHROME_VERSION | cut -d'.' -f1-3) && \
    echo "Using Chrome major.minor.build version: $CHROME_MAJOR_MINOR_BUILD" && \
    DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_MAJOR_MINOR_BUILD") && \
    echo "Chromedriver version found: $DRIVER_VERSION" && \
    wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

RUN google-chrome --version && chromedriver --version

WORKDIR /app
COPY . /app

CMD ["python3", "app.py"]
