# Production image for Rhythm Raiders (Rails 6.1 / Ruby 3.1.2 / Webpacker 5)
# Render などの PaaS に Docker デプロイするための本番用イメージ。
# ローカルデモ用は Dockerfile.demo を使うこと（別物）。
FROM ruby:3.1.2-bullseye

# System deps + Node 16 + Yarn.
# Webpacker 5 (webpack 4) は Node 16 が安定。libpq-dev は pg gem、libvips は
# image_processing、libsqlite3-dev は sqlite3 gem(dev/test) 用。
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends curl gnupg build-essential libpq-dev libsqlite3-dev libvips \
 && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npm install -g yarn \
 && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v 2.3.19

WORKDIR /app

# NOTE: Node 16 では webpack 4 がそのまま動くため --openssl-legacy-provider は付けない
#       (Node 16 に当該フラグは無く、付けると node が起動失敗する)
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT="development test"

# gem を先に入れてレイヤキャッシュを効かせる
COPY Gemfile Gemfile.lock ./
RUN bundle install

# JS 依存
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# アプリ本体
COPY . .

# アセットを事前コンパイル（Sprockets + Webpacker）。SECRET_KEY_BASE はビルド時のダミーでよい。
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bash", "bin/render-start.sh"]
