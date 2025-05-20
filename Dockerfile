FROM ubuntu:22.04

# Enable universe repository and install dependencies
RUN apt-get update && \
    sed -i '/universe/s/^# //g' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
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
        python3 \
        python3-pip \
        libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O /tmp/chrome.deb \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb

# Install ChromeDriver (with version matching)
RUN CHROME_VERSION=$(google-chrome --version | awk -F '[ .]' '{print $3"."$4"."$5}') && \
    echo "Chrome version: $CHROME_VERSION" && \
    DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION") && \
    echo "ChromeDriver version: $DRIVER_VERSION" && \
    wget -O /tmp/chromedriver.zip \
    "https://chromedriver.storage.googleapis.com/$DRIVER_VERSION/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# Copy app files
COPY . /app
WORKDIR /app
RUN pip3 install --no-cache-dir -r requirements.txt

# Create non-root user
RUN useradd -m appuser
USER appuser

CMD ["python3", "app.py"]
