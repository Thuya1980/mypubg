# Base image - Debian slim (သို့) Ubuntu ကို သုံးပါ
FROM ubuntu:22.04

# အရေးပါတဲ့ tools များ install
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    ca-certificates \
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
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Google Chrome 114.0.5735.90 version ကို install
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable=114.0.5735.90-1 && \
    rm -rf /var/lib/apt/lists/*

# ChromeDriver ကို manual နဲ့ install (version ကို Chrome version နဲ့ မိမိချိန်ညှိထား)
RUN wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# Optional: ChromeDriver, Google Chrome လမ်းကြောင်းစစ်ဆေးခြင်း (debug)
RUN google-chrome --version && chromedriver --version

# App ကို copy လုပ်ပြီး သက်ဆိုင်ရာ commands ထည့်ပါ
COPY . /app
WORKDIR /app

# Python requirements (သို့) သင့်အတွက် အခြား depencies install လုပ်ပါ (ဥပမာ)
# RUN pip install -r requirements.txt

# Flask app run (ဥပမာ)
CMD ["python3", "app.py"]
