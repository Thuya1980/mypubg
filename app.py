from flask import Flask, jsonify
import time
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Get current script directory
current_dir = os.path.dirname(os.path.abspath(__file__))
chrome_path = os.path.join(current_dir, "chrome", "chrome-win64", "chrome.exe")
chromedriver_path = os.path.join(current_dir,"chrome","chromedriver-win64","chromedriver.exe")

options = Options()
options.binary_location = chrome_path
options.add_argument("--headless=new")
options.add_argument("--disable-gpu")
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_argument("--disable-extensions")
options.add_argument("--no-sandbox")  # Helps in restricted environments
options.add_argument("--disable-dev-shm-usage")  # Avoids /dev/shm issues
options.add_argument("--disable-software-rasterizer")  # Avoid software rasterizer
options.add_argument("--window-size=1920,1080")  # Set window size to something normal

driver = None

def element_exists(by, value):
    try:
        driver.find_element(by, value)
        return True
    except:
        return False

application = Flask(__name__)  # Rename app to application

@application.route('/get-pubg-username/<player_id>', methods=['GET'])
def get_pubg_username(player_id):
    if not player_id.isdigit():
        return jsonify({'error': 'Invalid player ID'}), 400
    try:
        service = Service(chromedriver_path)
        driver = webdriver.Chrome(service=service, options=options)

        driver.get("https://www.midasbuy.com/midasbuy/mm/buy/pubgm")

        # Scroll to make sure popup appears
        driver.execute_script("window.scrollTo(0, 300);")

        # Wait and close popup if exists
        adClose_button = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, "div.PopGetPoints_close__L1oSl"))
        )
        driver.execute_script("arguments[0].click();", adClose_button)

        # Click the non-logged in arrow
        notLogin_button = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, "div.UserTabBox_login_text__8GpBN"))
        )
        driver.execute_script("arguments[0].click();", notLogin_button)

        # Enter Player ID
        input_box = WebDriverWait(driver, 5).until(
            EC.visibility_of_element_located((By.CSS_SELECTOR, "input[placeholder='Enter Player ID']"))
        )
        input_box.clear()
        input_box.send_keys(player_id)
        input_box.send_keys(Keys.ENTER)

        print("OK DONE")
        try:
            error = WebDriverWait(driver, 3).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "div.SelectServerBox_error_text__JWMz-"))
            )
            # If error found, return error
            return {'success': False, 'player_id': player_id, 'error': error.text}
        except:
            # No error appeared in 3 seconds, try to find username
            try:
                username_span = WebDriverWait(driver, 5).until(
                    EC.visibility_of_element_located((By.CSS_SELECTOR, "span.UserTabBox_name__4ogGM"))
                )
                username = username_span.text
                return {'success': True, 'player_id': player_id, 'username': username}
            except:
                # Neither error nor username found
                return {'success': False, 'player_id': player_id, 'error': 'Username not found, unknown page state'}
    except Exception as e:
        print("❌ Error:", str(e))
        if driver:
            with open("error_page.html", "w", encoding="utf-8") as f:
                f.write(driver.page_source)
            driver.save_screenshot("error.png")
            return {'success':False, 'player_id': player_id, 'error': str(e)}
    finally:
        if driver:
            driver.quit()

if __name__ == '__main__':
    application.run()
