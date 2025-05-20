FROM python:3.10-slim

# Install dependencies and chromium + chromedriver
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    libu2f-udev \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

# Symlink chromedriver to /usr/bin for easy access
RUN ln -sf /usr/lib/chromium/chromedriver /usr/bin/chromedriver

# Set environment variables for chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV PATH="${PATH}:/usr/bin"

# Set display port (headless Chrome)
ENV DISPLAY=:99

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run the app using gunicorn on port 10000
CMD ["gunicorn", "app:application", "--bind", "0.0.0.0:10000"]
