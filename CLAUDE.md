# CLAUDE.md

このファイルは Claude Code（claude.ai/code）がこのリポジトリで作業する際のガイドです。

## プロジェクト概要

**Rhythm Raiders** は、ユーザー（Member）が制作した楽曲（BGM）を投稿・共有し、再生・コメント・フォロー・いいねで交流する**音楽SNS型 Web アプリ**。Ruby on Rails のモノリス構成で、画面・API・DB を Rails 単体で持つ。元は **AWS** 上で稼働していたものを **Render + Supabase へ移植済み**（稼働中: https://rhythm-raiders.onrender.com ）。移植の経緯は `PROGRESS.md` に詳しい。

主な機能:
- 会員登録・ログイン（Devise）／管理者(Admin)＋ ActiveAdmin 管理画面
- 楽曲（CreatedTrack）の投稿・一覧・再生（wavesurfer.js / audiojs）・ActiveStorage で音源保存
- 楽曲へのAI動画紐づけ。**①ファイルを直接アップロード**（`has_one_attached :music_video_file`、MP4/WebM・50MBまで、詳細ページでミュート表示し波形プレーヤーと同期）と **②YouTube/Vimeo のURL埋め込み** の2通り。投稿者本人のみ設定可
- 楽曲へのAI静止画（ジャケット）添付。ActiveStorage の `has_one_attached :music_image`、PNG/JPEG/GIF/WebP・5MBまで。詳細ページで大きく、一覧・マイページで正方形サムネイル（共通パーシャル `layouts/_track_thumb`）。variant は使わずCSSでサイズ制御
- 投稿済み楽曲の編集（`member/created_tracks#edit`）。タイトル・ジャンル・Creator Word・AI動画URL を変更できる。**音源ファイル(`music_file`)の差し替えのみ不可**（いいね・コメントを保ったまま中身がすり替わるため）
- コメント(PostComment / commontator)・いいね(Like / acts_as_votable)・フォロー(Relationship / acts_as_follower)
- 通知(Notification / public_activity)・検索(ransack)・ページネーション(kaminari)

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| 言語 | Ruby 3.1.2 |
| フレームワーク | Rails 6.1.7 |
| DB | **開発: SQLite3** ／ **本番: PostgreSQL 17（Supabase・`pg` gem）**。旧AWSのMySQL(mysql2)からは移行済みで、`mysql2` は依存に無い |
| 認証 | Devise（`Member` と `Admin` の2モデル）＋ ActiveAdmin |
| フロント | Webpacker 5 + webpack 4（Bootstrap / jQuery / wavesurfer.js / turbolinks）＋ Sprockets(sass-rails) |
| ファイル保存 | ActiveStorage（開発: ローカルDisk ／ **本番: Supabase Storage（S3互換・aws-sdk-s3）**）。`R2_ACCESS_KEY_ID` の有無で `:cloudflare` / `:local` を切替（`config/environments/production.rb`） |
| アプリサーバ | Puma 3 |
| その他 gem | ransack / kaminari / acts_as_votable / acts_as_follower / commontator / public_activity / enum_help / dotenv-rails |

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
├── database.yml                   # dev=sqlite3 / prod=postgresql（DATABASE_URL を参照）
└── storage.yml                    # local(Disk) / cloudflare(S3互換=Supabase Storage)
db/
├── migrate/                       # 11マイグレーション（devise/created_tracks/likes/relationships/notifications 等）
├── schema.rb
├── seeds.rb
└── fixtures/                      # seed 用 mp3
```

## 重要な注意点

- **binstub と *.sh は LF 改行必須**。CRLF だと Linux/Docker で `/usr/bin/env: 'ruby\r'` エラーになる。`.gitattributes` で `bin/* text eol=lf` / `*.sh text eol=lf` を強制済み。Windows でも commit/checkout で壊さないこと。
- **Webpacker 5 / webpack 4 は Node 16 で動かす**。`Dockerfile.demo` は Node 16 を入れている。**`NODE_OPTIONS=--openssl-legacy-provider` は付けない**（Node 16 には当該フラグが無く、付けると node が起動失敗する。フラグが要るのは Node 17+）。
- **master.key / credentials**: 元の master.key は失われている（AWS/旧開発機のみ）。ローカルデモでは `bin/docker-demo.sh` が新規生成する。`config/master.key`・`.env` は gitignore 済み＝コミットしない。再生成された `config/credentials.yml.enc` もローカル専用（コミットしない）。
- `git add .` は使わず、関係ファイルを個別に add する。
- **kaminari の `.page/.per` はモデル直で呼ぶ**。`@member.created_tracks.page(...)` のように関連経由だと `ActiveRecord::AssociationRelation` になり `undefined method 'per'` で 500 になる。`CreatedTrack.page(params[:page]).per(5).where(member_id: ...)` の順で書く（`member/customers#mypage`・`member/created_tracks#index` とも同じ形）。
- **モデルを使う前に `db/schema.rb` で実在を確認する**。過去に「テーブルの無いモデル(`Post`)」「カラムの無い `enum`」が残っていた実績がある（2026-07-16 に一掃済み）。
- 管理画面のコメントモデレーション（`removed_by_admin` を立てる論理削除）は `DELETE /admin/created_tracks/:created_track_id/comments/:id`（`admin/comments#destroy`）。以前は実体の無い `posts` 配下にネストされていた。

## 本番デプロイ（Render + Supabase・稼働中）

| 役割 | サービス | 備考 |
|---|---|---|
| アプリ | **Render**（無料 Web Service・Docker） | 本番用 `Dockerfile` + `bin/render-start.sh`（db:prepare→seed→puma）。`render.yaml` は Blueprint |
| DB | **Supabase Postgres 17** | `DATABASE_URL` はダッシュボードで設定（`render.yaml` では `sync: false`） |
| ファイル | **Supabase Storage**（S3互換） | `R2_*` 環境変数で設定 |

- **`main` への push で自動再デプロイ。**
- **`DATABASE_URL` は必ず Supabase の「Session pooler」**（`aws-<n>-<region>.pooler.supabase.com:5432`）を使う。Direct connection はIPv6専用で Render（IPv4）から到達できない。詳細と障害時の対処は `PROGRESS.md` §4.6。
- 以前は Render の無料 Postgres を使っていたが、**30日で期限切れ→削除される**仕様で 2026-07-15 に消滅し本番停止した（→ Supabase へ移行済み）。Vercel は Rails モノリスが載らないため不適。
- 無料枠の注意: Render 無料 Web は15分でスリープ（次アクセスでコールドスタート30〜60秒）、Supabase 無料は7日でpause（削除はされない）。常時公開したいなら keep-alive ping か有料枠。
- 一時的に見せるだけなら ngrok/cloudflared でローカル(3100)を公開する手もある。

## 開発スタンス

- UI はこの環境からブラウザ目視できないため、フロント変更後の動作確認はユーザーに依頼し「未確認」と明示する。
- 気づいた設計・UX・潜在バグは一言添える（実装は指示があってから）。
