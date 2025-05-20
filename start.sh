#!/bin/bash
source .venv/bin/activate
gunicorn app:application --bind 0.0.0.0:10000
