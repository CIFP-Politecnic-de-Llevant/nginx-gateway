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

# RESERVES
FROM node:18-alpine as develop-stage-reserves
WORKDIR /app
COPY ./mf-reserves/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-reserves .

# build stage
FROM develop-stage-reserves as build-stage-reserves
RUN npm install
RUN quasar build

# PROFESSORAT MANAGER
FROM node:18-alpine as develop-stage-professorat-manager
WORKDIR /app
COPY ./mf-professorat-manager/package*.json ./
RUN npm install -g @quasar/cli
COPY ./mf-professorat-manager .

# build stage
FROM develop-stage-professorat-manager as build-stage-professorat-manager
RUN npm install
RUN quasar build

# # production stage
FROM nginx:1.25-alpine as production-stage

COPY /nginx-gateway/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage-core /app/dist/spa /usr/share/nginx/html/usuaris

# Esborrar si el projecte no fa servir aquest mòdul.
#El projecte gestsuite-autoinstall ho esborra automàticament, sinó s'ha de fer manualment
COPY --from=build-stage-convalidacions /app/dist/spa /usr/share/nginx/html/convalidacions

# Esborrar si el projecte no fa servir aquest mòdul.
#El projecte gestsuite-autoinstall ho esborra automàticament, sinó s'ha de fer manualment
COPY --from=build-stage-professorat-manager /app/dist/spa /usr/share/nginx/html/professorat-manager

# Esborrar si el projecte no fa servir aquest mòdul.
#El projecte gestsuite-autoinstall ho esborra automàticament, sinó s'ha de fer manualment
COPY --from=build-stage-grupscooperatius /app/dist/spa /usr/share/nginx/html/grupscooperatius

# Esborrar si el projecte no fa servir aquest mòdul.
#El projecte gestsuite-autoinstall ho esborra automàticament, sinó s'ha de fer manualment
COPY --from=build-stage-reserves /app/dist/spa /usr/share/nginx/html/reserves

COPY /nginx-gateway/certificate.crt /certificates/certificate.crt
COPY /nginx-gateway/certificate.key /certificates/certificate.key

CMD ["nginx", "-g", "daemon off;"]
