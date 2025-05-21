FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

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
    libgbm-dev \
    libgtk-3-0 \
    libxss1 \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome stable 124.0.6367.207
RUN wget -q https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_124.0.6367.207-1_amd64.deb && \
    apt-get update && apt-get install -y ./google-chrome-stable_124.0.6367.207-1_amd64.deb && \
    rm google-chrome-stable_124.0.6367.207-1_amd64.deb

# Install matching ChromeDriver
RUN wget -q https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/124.0.6367.207/linux64/chromedriver-linux64.zip -O /tmp/chromedriver.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chromedriver.zip /usr/local/bin/chromedriver-linux64

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

EXPOSE 10000

CMD ["gunicorn", "app:application", "--bind", "0.0.0.0:10000", "--workers", "1"]
