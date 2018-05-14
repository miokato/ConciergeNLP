FROM python:3.6.5-alpine3.7
MAINTAINER miokato

RUN apk add --update build-base

# Python
ENV PYTHONBUFFERED 1

# Mecab
ENV build_deps 'curl git bash file sudo openssh'
ENV dependencies 'openssl'

RUN apk add --update ${build_deps} \
    && apk add --update ${dependencies} \
     # Mecab
    && git clone https://github.com/taku910/mecab.git \
    && cd mecab/mecab \
    && ./configure --enable-utf8-only --with-charset=utf8 \
    && make \
    && make install \
    && cd / \
    # Mecab-ipadic
    && cd mecab/mecab-ipadic \
    && ./configure --with-charset=utf8 \
    && make \
    && make install \
    && cd / \
    # Neologd
    && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
    && mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y

# pip
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt

# My Library
RUN pip install -U git+https://github.com/miokato/MarkovGenerator

# clean
RUN apk del ${build_deps} \
    && rm -rf \
        mecab \
        mecab-ipadic-neologd

ADD . /code/

CMD gunicorn config.wsgi -b 0.0.0.0:$PORT
