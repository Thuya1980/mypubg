import os
import traceback
import subprocess
from flask import Flask, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

application = Flask(__name__)

def log(msg):
    print(msg)
    application.logger.info(msg)

@application.route('/versions')
def versions():
    try:
        chrome_version = subprocess.check_output(["google-chrome", "--version"]).decode().strip()
    except Exception as e:
        chrome_version = f"Error getting Chrome version: {str(e)}"
    try:
        driver_version = subprocess.check_output(["chromedriver", "--version"]).decode().strip()
    except Exception as e:
        driver_version = f"Error getting ChromeDriver version: {str(e)}"
    return jsonify({'chrome_version': chrome_version, 'chromedriver_version': driver_version})

@application.route('/get-pubg-username/<player_id>', methods=['GET'])
def get_pubg_username(player_id):
    log(f"Received request for player_id: {player_id}")

    if not player_id.isdigit():
        log("Invalid player ID format")
        return jsonify({'error': 'Invalid player ID. Must be numeric.'}), 400

    options = Options()
    options.binary_location = "/usr/bin/google-chrome"
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")

    driver = None
    try:
        service = Service("/usr/local/bin/chromedriver")
        driver = webdriver.Chrome(service=service, options=options)
        log("ChromeDriver started successfully")

        driver.get("https://www.midasbuy.com/midasbuy/mm/buy/pubgm")
        log("Loaded midasbuy page")
        driver.execute_script("window.scrollTo(0, 300);")

        # Close popup if present
        try:
            ad = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, "div.PopGetPoints_close__L1oSl"))
            )
            driver.execute_script("arguments[0].click();", ad)
            log("Popup closed")
        except Exception:
            log("No popup to close or timeout")

        # Click login button
        login_btn = WebDriverWait(driver, 15).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, "div.UserTabBox_login_text__8GpBN"))
        )
        login_btn.click()
        log("Clicked login button")

        # Enter Player ID
        input_box = WebDriverWait(driver, 15).until(
            EC.visibility_of_element_located((By.CSS_SELECTOR, "input[placeholder='Enter Player ID']"))
        )
        input_box.clear()
        input_box.send_keys(player_id)
        input_box.send_keys(Keys.ENTER)
        log(f"Entered player ID: {player_id}")

        # Check for error message
        try:
            err = WebDriverWait(driver, 5).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "div.SelectServerBox_error_text__JWMz-"))
            )
            log(f"Error found on page: {err.text}")
            return jsonify({'success': False, 'error': err.text, 'player_id': player_id})
        except Exception:
            log("No error message found, proceeding to get username")

        username = WebDriverWait(driver, 15).until(
            EC.visibility_of_element_located((By.CSS_SELECTOR, "span.UserTabBox_name__4ogGM"))
        )
        log(f"Found username: {username.text}")
        return jsonify({'success': True, 'username': username.text, 'player_id': player_id})

    except Exception as e:
        tb = traceback.format_exc()
        log(f"Exception occurred: {str(e)}\n{tb}")
        return jsonify({'success': False, 'error': str(e), 'player_id': player_id})

    finally:
        if driver:
            driver.quit()
            log("ChromeDriver quit")

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    application.run(host='0.0.0.0', port=port)
