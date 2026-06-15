#!/usr/bin/env bash
# Local demo bootstrap (runs inside the container). Idempotent.
set -e
cd /app

echo "==> [0/5] normalize binstub line endings (Windows CRLF -> LF for bin/rails, bin/webpack, etc.)"
sed -i 's/\r$//' bin/* 2>/dev/null || true

echo "==> [1/5] bundle install"
bundle config set --local without 'production'
bundle check || bundle install -j4

echo "==> [2/5] yarn install"
yarn install --check-files

echo "==> [3/5] master.key / credentials (regenerate locally if missing)"
if [ ! -f config/master.key ]; then
  rm -f config/credentials.yml.enc
  EDITOR=true bin/rails credentials:edit
fi

echo "==> [4/5] database prepare + seed"
bin/rails db:prepare
bin/rails db:seed

echo "==> [5/5] starting Rails server on http://localhost:3100 (container 0.0.0.0:3000)"
rm -f tmp/pids/server.pid
exec bin/rails s -b 0.0.0.0 -p 3000
