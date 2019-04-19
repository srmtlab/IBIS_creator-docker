FROM python:3.6.8-alpine3.9

LABEL maintainer Akira Kamiya <a.kamiya.208@gmail.com>

ENV MECAB_VERSION 0.996
ENV IPADIC_VERSION 2.7.0-20070801
ENV mecab_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE
ENV ipadic_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM
ENV APP_DIR /opt/IBIS_creator

WORKDIR /opt
RUN apk add swig g++ 
RUN apk add --no-cache --virtual .dl-deps curl make \
	# Install MeCab
	&& curl -SL -o mecab-${MECAB_VERSION}.tar.gz ${mecab_url} \
	&& tar -zxf mecab-${MECAB_VERSION}.tar.gz \
	&& cd mecab-${MECAB_VERSION} \
	&& ./configure --enable-utf8-only --with-charset=utf8 \
	&& make \
	&& make install \
	# Install ipadic
	&& cd ../ \
	&& curl -SL -o mecab-ipadic-${IPADIC_VERSION}.tar.gz ${ipadic_url} \
	&& tar -zxf mecab-ipadic-${IPADIC_VERSION}.tar.gz \
	&& cd mecab-ipadic-${IPADIC_VERSION} \
	&& ./configure --with-charset=utf8 \
	&& make \
	&& make install \
	&& cd ../ \
	&& rm -Rf mecab* \
	&& apk del .dl-deps 

# download source code
WORKDIR ${APP_DIR}
RUN mkdir static
RUN apk add --no-cache --virtual .dl-deps git\
	&& git clone https://github.com/srmtlab/IBIS_creator.git ${APP_DIR} \
	&& apk del .dl-deps \
	&& pip install -r requirements/production.txt 

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

COPY startup.sh ${APP_DIR}/
RUN chmod +x ${APP_DIR}/startup.sh

VOLUME ${APP_DIR}/SECRET_FILES/
VOLUME ${APP_DIR}/static/

COPY local_settings.json ${APP_DIR}/SECRET_FILES/
RUN python3 manage.py collectstatic --settings config.settings.production

EXPOSE 8000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["./startup.sh"]
