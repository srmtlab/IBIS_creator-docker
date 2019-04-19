#!/bin/sh

python3 SetUp.py
python3 manage.py migrate --settings config.settings.production
python3 manage.py makemigrations IBIS_creator --settings config.settings.production
python3 manage.py migrate --settings config.settings.production
daphne -b 0.0.0.0 -p 8000 config.asgi:application
