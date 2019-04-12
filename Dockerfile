FROM python:3.6.8-alpine3.9

LABEL maintainer Akira Kamiya <a.kamiya.208@gmail.com>

ENV APP_DIR /opt/

WORKDIR ${APP_DIR}

RUN curl -SL https://github.com/srmtlab/IBIS_creator/archive/master.tar.gz | tar -zxvf xxxx.tar.gz
	&& cd IBIS_creator \
	&& apt install mecab mecab-ipadic-utf8 libmecab-dev swig \
	&& pip install -r requirements/production.txt \
	&& python3 Setup.py 

RUN python3 manage.py collectstatic --settings config.settings.production \
	&& python3 manage.py migrate --settings config.settings.production \ 
	&& python3 manage.py makemigrations IBIS_creator --settings config.settings.production \
	&& python3 manage.py migrate --settings config.settings.production \

VOLUME ${APP_DIR}/db.sqlite3
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["daphne", "-p", "8000", "config.asgi:application"]
