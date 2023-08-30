# CORE
FROM node:18-alpine as develop-stage-core
WORKDIR /app
COPY ./mf-core/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-core .

# build stage
FROM develop-stage-core as build-stage-core
RUN npm install
RUN quasar build

# CONVALIDACIONS
FROM node:18-alpine as develop-stage-convalidacions
WORKDIR /app
COPY ./mf-convalidacions/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-convalidacions .

# build stage
FROM develop-stage-convalidacions as build-stage-convalidacions
RUN npm install
RUN quasar build

# GRUPS COOPERATIUS
FROM node:18-alpine as develop-stage-grupscooperatius
WORKDIR /app
COPY ./mf-grupscooperatius/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-grupscooperatius .

# build stage
FROM develop-stage-grupscooperatius as build-stage-grupscooperatius
RUN npm install
RUN quasar build

# WEB IES MANACOR
FROM node:18-alpine as develop-stage-webiesmanacor
WORKDIR /app
COPY ./mf-webiesmanacor/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-webiesmanacor .

# build stage
FROM develop-stage-webiesmanacor as build-stage-webiesmanacor
RUN npm install
RUN quasar build

# # production stage
FROM nginx:1.23.4-bullseye as production-stage

ARG CONVALIDACIONS
ARG WEBIESMANACOR
ARG GRUPSCOOPERATIUS

RUN echo "hola2"
RUN echo "${CONVALIDACIONS}"
RUN echo "${WEBIESMANACOR}"
RUN echo "${GRUPSCOOPERATIUS}"
RUN echo "adeu234"

COPY /nginx-gateway/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage-core /app/dist/spa /usr/share/nginx/html/usuaris

# TODO: COPY no és part de RUN, per això falla el condicional
# RUN if [ "$CONVALIDACIONS" = true ]; then COPY --from=build-stage-convalidacions /app/dist/spa /usr/share/nginx/html/convalidacions; fi
COPY --from=build-stage-convalidacions /app/dist/spa /usr/share/nginx/html/convalidacions

# TODO: COPY no és part de RUN, per això falla el condicional
# RUN if [ "$WEBIESMANACOR" = true ]; then COPY --from=build-stage-webiesmanacor /app/dist/spa /usr/share/nginx/html/webiesmanacor; fi
COPY --from=build-stage-webiesmanacor /app/dist/spa /usr/share/nginx/html/webiesmanacor

COPY --from=build-stage-grupscooperatius /app/dist/spa /usr/share/nginx/html/grupscooperatius

# Instal·lem certbot pel certificat SSL
# Ho instal·lem amb PIP i no Snap (com recomana) perquè en entorns virtualitzats Snap no funciona
# Més info: https://certbot.eff.org/instructions?ws=nginx&os=pip
RUN apt update
RUN apt upgrade -y
RUN apt install python3 python3-venv libaugeas0 -y
RUN python3 -m venv /opt/certbot/
RUN /opt/certbot/bin/pip install --upgrade pip
RUN /opt/certbot/bin/pip install certbot certbot-nginx
RUN ln -s /opt/certbot/bin/certbot /usr/bin/certbot
RUN echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | tee -a /etc/crontab > /dev/null

# IMPORTANT: a partir d'aquí executar "certbot --nginx" manualment

CMD ["nginx", "-g", "daemon off;"]
