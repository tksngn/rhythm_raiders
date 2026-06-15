#!/usr/bin/env bash
# Render(本番)用の起動スクリプト。DB準備 → seed → puma 起動。
# NOTE: LF改行必須（.gitattributes の bin/* text eol=lf で保証）。
set -e

# DB を作成しスキーマ反映（既存なら未適用マイグレーションのみ）
bundle exec rails db:prepare
# デモデータ投入（find_or_create_by! なので冪等）
bundle exec rails db:seed

# TCP の $PORT をフォアグラウンドで待ち受け
bundle exec puma -C config/puma.rb
