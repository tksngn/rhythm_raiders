# CLAUDE.md

このファイルは Claude Code（claude.ai/code）がこのリポジトリで作業する際のガイドです。

## プロジェクト概要

**Rhythm Raiders** は、ユーザー（Member）が制作した楽曲（BGM）を投稿・共有し、再生・コメント・フォロー・いいねで交流する**音楽SNS型 Web アプリ**。Ruby on Rails のモノリス構成で、画面・API・DB を Rails 単体で持つ。元々は **AWS** 上で稼働していたものを移植中。

主な機能:
- 会員登録・ログイン（Devise）／管理者(Admin)＋ ActiveAdmin 管理画面
- 楽曲（CreatedTrack）の投稿・一覧・再生（wavesurfer.js / audiojs）・ActiveStorage で音源保存
- 投稿(Post)・コメント(PostComment / commontator)・いいね(Like / acts_as_votable)・フォロー(Relationship / acts_as_follower)
- 通知(Notification / public_activity)・検索(ransack)・ページネーション(kaminari)

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| 言語 | Ruby 3.1.2 |
| フレームワーク | Rails 6.1.7 |
| DB | **開発: SQLite3** ／ 本番: MySQL（mysql2・元AWS RDS想定） |
| 認証 | Devise（`Member` と `Admin` の2モデル）＋ ActiveAdmin |
| フロント | Webpacker 5 + webpack 4（Bootstrap / jQuery / wavesurfer.js / turbolinks）＋ Sprockets(sass-rails) |
| ファイル保存 | ActiveStorage（開発: ローカルDisk ／ 本番: S3・aws-sdk-s3） |
| アプリサーバ | Puma 3 |
| その他 gem | ransack / kaminari / acts_as_votable / acts_as_follower / commontator / public_activity / enum_help / carrierwave / dotenv-rails |

## ローカルでの起動（Docker・推奨）

このリポジトリには **ローカルデモ用の Docker 構成**（`Dockerfile.demo` / `docker-compose.demo.yml` / `bin/docker-demo.sh`）が含まれる。Windows/Mac/Linux 問わず、Ruby を直接入れずに動かせる。

```bash
# 起動（初回はイメージbuild + gem/yarn install で数分）
docker compose -f docker-compose.demo.yml up --build
# 停止
docker compose -f docker-compose.demo.yml down
```

- URL: **http://localhost:3100**（ホスト3100 → コンテナ3000。他プロジェクトとの衝突回避のため3100）
- `bin/docker-demo.sh` が自動で実行する処理: binstub の改行正規化 → `bundle install` → `yarn install` → **master.key 新規生成**（ローカル用・元キー不要）→ `db:prepare` + `db:seed` → `rails s`
- seed 投入データ（`db/seeds.rb`）:
  - 会員: `test1@example.com` / `password01`（test2/test3 も同様）
  - 管理者: `.env` の `ADMIN_EMAIL` / `ADMIN_PASSWORD`（デモ既定 `admin@example.com` / `password`）
  - 楽曲3件（Fantasy World / Medieval Cityscape / Turmoil of Battle）

### 主要URL

| 画面 | パス |
|---|---|
| トップ（会員トップ） | `/`（`homes#member_top`） |
| 会員ログイン | `/members/sign_in` |
| 管理ログイン | `/admin/sign_in` |
| 楽曲検索 | `/search` |
| About | `/homes/about` |

## アーキテクチャ / ディレクトリ

```
app/
├── controllers/
│   ├── homes_controller.rb        # トップ・About
│   ├── search_controller.rb       # ransack 検索
│   ├── member/                    # 会員機能（devise各種 + created_tracks/posts/likes/relationships/notifications…）
│   └── admin/                     # 管理機能（devise各種 + members/posts/created_tracks/comments）
├── models/                        # Admin / Member / CreatedTrack / Post / PostComment / Like / Relationship / Notification
└── javascript/packs/              # Webpacker エントリ（application.js, homes）
config/
├── routes.rb                      # root→homes#member_top, devise_for :admin/:member, namespace admin/member
├── database.yml                   # dev=sqlite3 / prod=mysql2
└── storage.yml                    # local(Disk) / amazon(S3)
db/
├── migrate/                       # 8マイグレーション（devise/created_tracks/likes/relationships/notifications 等）
├── schema.rb
├── seeds.rb
└── fixtures/                      # seed 用 mp3
```

## 重要な注意点

- **binstub と *.sh は LF 改行必須**。CRLF だと Linux/Docker で `/usr/bin/env: 'ruby\r'` エラーになる。`.gitattributes` で `bin/* text eol=lf` / `*.sh text eol=lf` を強制済み。Windows でも commit/checkout で壊さないこと。
- **Webpacker 5 / webpack 4 は Node 16 で動かす**。`Dockerfile.demo` は Node 16 を入れている。**`NODE_OPTIONS=--openssl-legacy-provider` は付けない**（Node 16 には当該フラグが無く、付けると node が起動失敗する。フラグが要るのは Node 17+）。
- **master.key / credentials**: 元の master.key は失われている（AWS/旧開発機のみ）。ローカルデモでは `bin/docker-demo.sh` が新規生成する。`config/master.key`・`.env` は gitignore 済み＝コミットしない。再生成された `config/credentials.yml.enc` もローカル専用（コミットしない）。
- `git add .` は使わず、関係ファイルを個別に add する。

## デプロイ方針（移植）

元は AWS。アーキテクチャがモノリスのため、Wave-Nexus（Next.js+NestJS+Supabase）とは対応が異なる。

| サービス | 適用 | 備考 |
|---|---|---|
| **Render** | ◎ アプリ本体のホスト先に最適 | Rails 常駐サーバをそのまま動かせる |
| **Supabase** | ○ DB（Postgres）として利用可 | 本番DBが MySQL のため `mysql2`→`pg` 改修が必要 |
| **Vercel** | ✗ 不適 | Rails モノリスは載らない。別フロントが存在しない |

- 無料枠の注意: Render 無料 Web Service は15分でスリープ（次アクセスでコールドスタート30〜60秒）、Supabase 無料は7日でpause。常時公開したい場合は keep-alive ping か有料枠を検討。
- 一時的に見せるだけなら ngrok/cloudflared でローカル(3100)を公開する手もある。

## 開発スタンス

- UI はこの環境からブラウザ目視できないため、フロント変更後の動作確認はユーザーに依頼し「未確認」と明示する。
- 気づいた設計・UX・潜在バグは一言添える（実装は指示があってから）。
