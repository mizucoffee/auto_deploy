FROM nginx:1.21.3
LABEL maintainer="develop@mizucoffee.net"

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update && \
  apt-get install -y build-essential git nodejs python libssl-dev zlib1g-dev curl nano libpq-dev && \
  npm install -g yarn && \
  rm /etc/nginx/conf.d/default.conf && \
  git clone https://github.com/rbenv/rbenv.git /root/.rbenv

RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  apt-get update && \
  apt-get install -y google-chrome-stable

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
