from flask import Flask, jsonify
import requests
from bs4 import BeautifulSoup

application = Flask(__name__)

@application.route('/get-pubg-username/<player_id>', methods=['GET'])
def get_pubg_username(player_id):
    if not player_id.isdigit():
        return jsonify({'error': 'Invalid player ID'}), 400

    try:
        url = "https://www.midasbuy.com/midasbuy/mm/buy/pubgm"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }

        session = requests.Session()
        response = session.get(url, headers=headers)

        if response.status_code != 200:
            return jsonify({'success': False, 'error': 'Failed to load Midasbuy page'})

        # This part may fail if Midasbuy uses dynamic JS rendering or anti-bot protection
        soup = BeautifulSoup(response.text, 'html.parser')

        # NOTE: You cannot submit forms or click buttons without Selenium or JavaScript
        # So this is a placeholder only — you'd need a real API from Midasbuy or browser automation
        return jsonify({
            'success': False,
            'player_id': player_id,
            'error': 'Midasbuy requires JavaScript. Cannot continue without browser.'
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

if __name__ == '__main__':
    application.run()
