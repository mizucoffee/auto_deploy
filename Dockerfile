FROM nginx:1.21.3
LABEL maintainer="develop@mizucoffee.net"

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update && \
  apt-get install -y build-essential git nodejs python ruby && \
  npm install -g yarn && \
  rm /etc/nginx/conf.d/default.conf

COPY watcher /watcher
COPY nginx.conf /etc/nginx/nginx.conf 

WORKDIR /watcher
RUN yarn

CMD [ "node", "." ]