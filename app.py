import os
from flask import Flask, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

application = Flask(__name__)

def create_driver():
    options = Options()
    options.binary_location = "/usr/bin/google-chrome"
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--disable-blink-features=AutomationControlled")

    service = Service("/usr/local/bin/chromedriver")
    driver = webdriver.Chrome(service=service, options=options)
    return driver

@application.route('/get-pubg-username/<player_id>', methods=['GET'])
def get_pubg_username(player_id):
    if not player_id.isdigit():
        return jsonify({'error': 'Invalid player ID'}), 400

    driver = None
    try:
        driver = create_driver()

        driver.get("https://www.midasbuy.com/midasbuy/mm/buy/pubgm")
        driver.execute_script("window.scrollTo(0, 300);")

        # Close popup if appears
        try:
            ad = WebDriverWait(driver, 3).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, "div.PopGetPoints_close__L1oSl"))
            )
            driver.execute_script("arguments[0].click();", ad)
        except:
            pass

        # Click login button
        login_btn = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, "div.UserTabBox_login_text__8GpBN"))
        )
        login_btn.click()

        # Enter Player ID
        input_box = WebDriverWait(driver, 5).until(
            EC.visibility_of_element_located((By.CSS_SELECTOR, "input[placeholder='Enter Player ID']"))
        )
        input_box.clear()
        input_box.send_keys(player_id)
        input_box.send_keys(Keys.ENTER)

        # Check for error message
        try:
            err = WebDriverWait(driver, 3).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "div.SelectServerBox_error_text__JWMz-"))
            )
            return jsonify({'success': False, 'error': err.text, 'player_id': player_id})
        except:
            username = WebDriverWait(driver, 5).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "span.UserTabBox_name__4ogGM"))
            )
            return jsonify({'success': True, 'username': username.text, 'player_id': player_id})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e), 'player_id': player_id})
    finally:
        if driver:
            driver.quit()

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    application.run(host='0.0.0.0', port=port)
