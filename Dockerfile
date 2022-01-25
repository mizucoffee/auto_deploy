FROM nginx:1.21.3
LABEL maintainer="develop@mizucoffee.net"

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update && \
  apt-get install -y build-essential git nodejs python libssl-dev zlib1g-dev curl nano libpq-dev gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libgdm-dev && \
  npm install -g yarn && \
  rm /etc/nginx/conf.d/default.conf && \
  git clone https://github.com/rbenv/rbenv.git /root/.rbenv

ENV PATH=/root/.rbenv/shims:/root/.rbenv/bin:/usr/local/sbin:$PATH

RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build && \
  rbenv install 3.0.0 && \
  rbenv global 3.0.0 && \
  gem install bundler

COPY watcher /watcher
COPY nginx.conf /etc/nginx/nginx.conf 

WORKDIR /watcher
RUN yarn
RUN npm config set cache /.npm --global

CMD [ "node", "." ]