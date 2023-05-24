# CORE
FROM node:16.6.2-alpine as develop-stage-core
WORKDIR /app
COPY ./mf-core/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-core .

# build stage
FROM develop-stage-core as build-stage-core
RUN npm install
RUN quasar build

# CONVALIDACIONS
FROM node:16.6.2-alpine as develop-stage-convalidacions
WORKDIR /app
COPY ./mf-convalidacions/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-convalidacions .

# build stage
FROM develop-stage-convalidacions as build-stage-convalidacions
RUN npm install
RUN quasar build

# GRUPS COOPERATIUS

# WEB IES MANACOR
FROM node:16.6.2-alpine as develop-stage-webiesmanacor
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

COPY /nginx-gateway/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage-core /app/dist/spa /usr/share/nginx/html/usuaris

RUN if [ "$CONVALIDACIONS" = true ]; then COPY --from=build-stage-convalidacions /app/dist/spa /usr/share/nginx/html/convalidacions ; fi

RUN if [ "$WEBIESMANACOR" = true ]; then COPY --from=build-stage-webiesmanacor /app/dist/spa /usr/share/nginx/html/webiesmanacor ; fi
CMD ["nginx", "-g", "daemon off;"]
