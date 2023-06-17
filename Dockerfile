FROM node:lts as builder

WORKDIR /app

USER root

COPY package.json ./
COPY tsconfig.json ./

# only
RUN yarn --network-timeout 100000

# # Copy node packages into container
COPY . ./

# Run inside the container. Note that each command creates an additional layer, so it's
# important to only execute a single build command

# Required in order to set docusaurus url in docusaurus.config.js. ARG also defined in docker-compose.yml and is required.
# ARG REACT_APP_DOMAIN
# ENV REACT_APP_DOMAIN $REACT_APP_DOMAIN

# Build only
RUN yarn build

FROM nginx:alpine


# Build
# Copy dist folders from multi-stage build into nginx container
COPY --from=builder /app/build /usr/share/nginx/html/frontend

# COPY ./nginx/index.html /usr/share/nginx/html/frontend/index.html

COPY ./nginx/common.conf /etc/nginx/templates/default.conf.template


WORKDIR /usr/share/nginx/html/

# NOTE: NGINX 1.19 and above have a feature which will read *.conf.template files
# in /etc/nginx/templates/, change out environment variables and output to /etc/nginx/conf.d/*.conf
# This feature ONLY works if we use CMD below, and NOT entrypoint
# ENTRYPOINT ["nginx", "-g", "daemon off;"]
CMD ["nginx", "-g", "daemon off;"]