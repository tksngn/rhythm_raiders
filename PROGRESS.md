# PROGRESS — Rhythm Raiders 移植・改修記録

元 AWS で稼働していた音楽SNS（Rails 6.1 / Ruby 3.1.2 モノリス）を **Render に移植**し、
全画面を **ダーク＋ネオン（ティール #00ffcc 基調）** に刷新、あわせて機能・UX を改善した記録。

公開URL: https://rhythm-raiders.onrender.com

---

## 1. Render への本番デプロイ（移植）

AWS(MySQL/S3/nginx+puma) 前提だった構成を、Render(無料・Docker) + Render Postgres へ移植。

| 区分 | 内容 |
|---|---|
| DB | 本番を **MySQL → PostgreSQL** に変更（`Gemfile` mysql2→pg、`config/database.yml` を `DATABASE_URL` 利用の単一 production 定義に整理、`Gemfile.lock` も更新） |
| コンテナ | 本番用 `Dockerfile`（Ruby 3.1.2 + Node 16、`assets:precompile` 込み）、`.dockerignore`、起動スクリプト `bin/render-start.sh`（db:prepare→seed→puma）を追加 |
| Blueprint | `render.yaml`（無料 Web(Docker) + 無料 Postgres + 環境変数）を追加 |
| 起動修正 | `config/puma.rb` が旧AWS用に **unixソケット+デーモン化** していたため Render で起動失敗 → TCP `$PORT` フォアグラウンド起動へ修正（`Rails`定数/`present?` などロード前に使えない記述も除去）。`tmp/pids` 不在による pidfile エラーも起動時 mkdir で解消 |
| 認証情報 | 元 master.key 喪失のため、本番は `SECRET_KEY_BASE` 環境変数で運用（credentials 非依存） |

### 本番特有の「DBは永続・ファイルは揮発」対策
Render 無料は永続ディスク不可。DB(Postgres)は残るが、アップロードファイルは再起動で消える。
seed が `find_or_create_by!` でレコード存在時にファイル登録をスキップしていたため **音源/画像が 404** になっていた。

- **音源(CarrierWave)**: `db/seeds.rb` を、レコードの有無に関わらず **起動毎にファイルを登録し直す** 方式へ（`find_or_initialize_by` + 毎回 `music_file` 代入 + `save!`）。
- **プロフィール画像(ActiveStorage)**: 古い添付blobが実ファイル欠落で404になるため、seed で **purge して起動毎に再生成**。

> 既知の制約: 無料Webは15分無アクセスでスリープ（次アクセスにコールドスタート）、無料Postgresは作成から約30日で削除、訪問者の新規アップロードは再起動で消える（デモ用途として許容）。
>
> ※ このうち「アップロードが消える」は §4.5 で、「無料Postgresが削除される」は **§4.6 で解消済み**（実際に 2026-07-15 に削除され本番停止したため Supabase Postgres へ移行）。

---

## 2. UI 刷新（ダーク＋ネオン）

スタイルは Webpacker 経由の `app/javascript/stylesheets/application.scss` に集約。
半透明ガラスカード（glassmorphism）＋ティールのネオンアクセントで全画面を統一。

| 画面 | 主な内容 |
|---|---|
| トップ `/` | ロゴ＋検索＋ナビをガラスカードに集約、ネオンボタン（ホバー発光）。ロゴは全体表示＋グロー |
| ログイン / サインアップ | glassカード化、共通 `auth-*` スタイル、規約は折りたたみ（details）。崩れたHTMLを修正 |
| 楽曲一覧（会員 / ゲスト） | 共通クラス `.tracks-page` に集約。背景に暗オーバーレイ、楽曲カードをガラス化、**動くイコライザー** とカード登場/ホバー演出。配置・余白も調整 |
| 楽曲詳細 | ティール×**バイオレット**の2色グラデでニュアンス変化。2カラム（情報＋プレーヤー / コメント）。崩れHTML修正 |
| マイページ | プロフィール / My Tracks / Follow・Follower / Good Sound をガラスカード化 |
| About | 日英2枚のガラスカード。崩れHTML（h1/h4不一致, typo）を修正 |
| 楽曲投稿/会員編集 `new` | 2フォームを共通 `auth-*` でガラスカード化 |
| メンバー詳細 / フォロー・フォロワー一覧 | `member-list` のカードグリッドに統一 |
| 通知一覧 / 退会確認・完了 | ガラスカード化 |
| 検索結果 | 共通カードグリッドに統一 |
| 背景オーバーレイ | 各ページのオーバーレイを薄くして背景画像が見えるよう調整 |

---

## 3. 機能修正・バグ修正

- **プロフィール編集が保存不能だったのを修正**: `update` は `params.require(:member)` なのにフォームが `@created_track` バインドだった → `@member` バインドへ。未定義ヘルパ `attachment_field`/`attachment_image_tag` を標準の `file_field`/`image_tag` へ置換。許可カラム（name/creater_name/email/phone_number/gender/profile/profile_image）を全て編集可能に。
- **波形(wavesurfer.js)の初期化漏れを修正**: 未来の `turbolinks:load` 待ち＋ハンドラ重複が原因で初回表示されなかった → **即時初期化（多重防止＋前インスタンス破棄）** に変更。これに伴い各画面の「waveが表示されない時はリロード」注意書きを削除。wavesurfer v7 で廃止の `backend: 'MediaElement'` も除去。
- 各画面の壊れた HTML タグ（未閉じ `<h1>`/`<h5>`、`<h …>…</h4>` 不一致、typo "Seenarios" 等）を整理。
- フォローボタンの `method: :POST` を `:post` に修正（rails-ujs の data-method 厳密比較対策）。
- **ランダム並び替えが本番でクラッシュする移植バグを修正**: `Rails.env.production? ? "RAND()" : "RANDOM()"` だったが本番は MySQL→**PostgreSQL** になったため `RAND()` は存在せずエラー。両環境で動く `RANDOM()` に統一。
- **楽曲一覧の N+1 を解消**: 並び替えロジックを `sorted_created_tracks` に共通化し `preload(:member, :likes)` を付与。ビューの `likes.count`→`likes.size`（preload配列を利用）、`CreatedTrack#liked_by?` も preload 済みなら追加クエリ無しで判定するよう変更。
- **一覧の500を修正**: Kaminari は `CreatedTrack.page.per` のようにモデル直で呼ぶ必要があり、`includes(...).page.per` だと `per` が付かず `NoMethodError`。`CreatedTrack.page.per.preload(...)` に修正。
- **good/comment 並び替えの Postgres エラー**: join 時に `group(:id)` が曖昧 → `group("created_tracks.id")` に。
- **プロフィール画像の InvariableError(500) を解消**: `Member#get_profile_image` の `variant(リサイズ)` は本番の画像processor依存で特にPNGアップロード後に落ちるため廃止し、添付をそのまま返す（表示サイズはCSS）。プレビュー巨大化も `.profile-img` のサイズ指定で修正。
- **更新後リダイレクトの不正URL**: `mypage_member_customers_path(@member.id)` が `/member/customers/mypage.1` になる問題を修正（idを渡さない）。
- **会員側コントローラの不具合**: `likes#destroy` のいいね不在時 `nil.destroy`(500) を `&.destroy` に、`=`代入の無意味ガード除去、`redirect_back` 化（likes/post_comments/relationships）。
- **管理側の不具合**: `unban` の `update(active:)`→`is_active:`（列名誤りで500）、`comments#destroy` の `Comment`(不在)→`PostComment`、`posts`(テーブル不在)に存在ガード追加。未使用かつ壊れたパーシャル（admin/comments/_show, admin/posts/_show）を削除。

---

## 4. 体験・見栄え改善

- **共通ヘッダー**（`app/views/layouts/_header.html.erb`）: 全画面に sticky のガラスナビを追加。ログイン状態で Tracks/Post/Mypage/About/通知ベル/Logout、未ログインで About/Login/SignUp。導入に伴いページ内の重複ナビを整理。
- **OGP / Twitter Card**: リンク共有時にカード表示されるよう `<head>` にメタ追加（`content_for(:title)`/`(:description)` で上書き可）。
- **フラッシュメッセージ**: 右上トースト化（スライドイン＋4秒で自動フェード）。
- **フッター**: ダークテーマに刷新（ブランド＋リンク＋著作権）。
- **パフォーマンス**: `background-attachment: fixed` を除去しスクロール時の描画負荷/モバイルのカクつきを軽減。
- **背景/ロゴ画像の再圧縮**: `sharp` の一時スクリプト（コミットせず手元実行）で全 JPG を **mozjpeg 品質85・寸法維持**で再エンコード。**合計 約19.6MB → 4.7MB（-76%）**。ファイル名・画素寸法は不変のためレイアウトへの影響なし。元画像は git 履歴に残存（復元可）。例: Sepik 814→325KB、28350918_m 538→103KB、dragoon 385→150KB、1174232 1641→347KB、yuheng 666→54KB。
- **管理画面の刷新（会員と分離）**: 管理は独自の `admin` 名前空間（ActiveAdmin ではない）。ヘッダーを管理対応にし、管理中は ADMIN バッジ＋Members/Logout のみ（会員ナビは非表示）。画面は会員のダークと**正反対のライト基調＋ティール**のフロストガラスに統一（ログイン/メンバー管理・詳細・編集/投稿一覧/利用停止通知）。配置（中央寄せ・ボタン間隔）も調整。
- **運営コメント削除のソフト削除＋墓標**: `post_comments.removed_by_admin` を追加し、運営削除は物理削除せずフラグ化。楽曲詳細では「コミュニティガイドラインに基づき運営により削除されました」を中立表示（炎上防止）。会員自身の削除は従来どおり物理削除。
- **コミュニティガイドライン追加**: `/homes/guidelines`（尊重/禁止事項/著作権/違反対応・日英）。墓標とフッターからリンク。
- **公開URL/ログイン情報を README に追記**（管理者PWは非公開＝環境変数管理）。

---

## 4.5 アップロードの永続化（Supabase Storage）

無料Renderはディスク非永続で、投稿曲・画像が再デプロイで消えていた問題を解消。**Supabase Storage（無料・カード不要・S3互換）** に保存して永続化した。

経緯（試行錯誤の記録）:
- 当初 **Cloudflare R2** を検討 → R2はカード登録必須のため見送り、**Supabase Storage** に変更。
- 音源は当初 **CarrierWave + fog-aws(storage :fog)** でR2/S3対応を実装したが、**fog-aws と Supabase のS3実装が非互換**（`captures for nil` / vhost名前解決失敗 / PUT 404 など）で不安定。
- → 音源を **CarrierWave から ActiveStorage(aws-sdk-s3) へ移行**して安定化（`has_one_attached :music_file`）。fog-aws は撤去。
- **波形のCORS問題**を避けるため、音源は **`rails_storage_proxy_path`（同一オリジンでストリーミング）** で配信（公開バケット不要・CORS設定不要）。
- プロフィール画像(ActiveStorage)も同じ Supabase(S3サービス) に保存。
- ハマりどころ:
  - `R2_ENDPOINT` 等に `<ref>` プレースホルダを実値へ置換し忘れ → `URI::InvalidURIError`。
  - リージョン必須のため **`R2_REGION`** をENV化（既定 `auto`）。
  - 移行後、旧CarrierWave用の **`music_file`(string, NOT NULL) カラム**が残り投稿時に `PG::NotNullViolation` → **マイグレーションで該当カラム削除**して解決。
  - seed は **ストレージ失敗でもサイトが落ちない**よう `begin/rescue` で堅牢化（warnログのみ）。
- 設定（Render環境変数。R2_* は汎用S3ラベルとして流用。未設定ならローカル保存にフォールバック）:
  `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` / `R2_ENDPOINT`(=`https://<ref>.supabase.co/storage/v1/s3`) / `R2_BUCKET` / `R2_REGION` / `R2_PUBLIC_URL`。
- 結果: **投稿曲のアップロード・波形表示・再生・再デプロイ後の保持**まで確認OK。

---

## 4.6 本番DBの消滅と Supabase Postgres への移行（2026-07-15 障害）

**Render 無料 Postgres が期限切れで削除され、本番が全面停止した。** 4.5 でファイルの永続化は解決していたが、DB そのものが消えるケースが残っていた（§5 に「約30日で削除」と記載していた既知リスクが顕在化した形）。

- **事象**: `db:prepare` が `PG::ConnectionBad: could not translate host name "dpg-d8nvkd3bc2fs73feqtd0-a" to address` で失敗し続け、`bin/render-start.sh` が `set -e` で停止 → puma に到達せず「No open ports detected」でデプロイ失敗。
- **原因**: 接続拒否ではなく **DNS が引けない**＝DBインスタンスの消滅。Postgres 側ログに `2026-07-15T14:24:30Z database system is shut down` が記録されていた。Render 無料DBは**作成から30日で期限切れ → 14日の猶予後にデータごと削除**（無料枠はバックアップ非対応）。
- **切り分け**: 直前の push（AI動画機能, 07-16 12:05 UTC）とは無関係。DB消滅はその**約22時間前**。本番 `Dockerfile` をローカルでビルドし、実 Postgres に対して `db:prepare`→`db:seed`→ヘルスチェック200 まで完走することを確認済み。
- **対応**: DBを **Supabase Postgres** へ移行。`render.yaml` の `databases:` ブロックを削除し、`DATABASE_URL` を `sync: false`（ダッシュボード設定）に変更。Supabase 無料は7日無アクセスで **pause するが削除されない**ため、消滅リスクが無くなる。
- **接続方式の注意（重要）**: 必ず **Session pooler**（`aws-<n>-<region>.pooler.supabase.com:5432`。本プロジェクトは `aws-1-ap-northeast-1`）を使う。Supabase の Direct connection は 2024-01-15 以降 **IPv6 専用**で Render（IPv4）から到達できない。Session pooler は IPv4 プロキシ経由で無料。Transaction pooler(6543) は prepared statements の無効化が必要。取得場所は Connect → Direct(Connection string) → Connection Method: Session pooler → Type: URI。
- **データ**: 本番の投稿データは復旧不可（バックアップ無し・インスタンスごと削除）。新DB接続後は `db:prepare` + `db:seed` でデモデータが再生成される。Supabase Storage 側の音源blobは残るが参照レコードが無く孤児化する。
- **結果**: 2026-07-16 復旧完了。Supabase は **PostgreSQL 17**。Rails 6.1 との組み合わせをローカル（本番Dockerfile + postgres:17）で検証し、`db:prepare`→`db:seed`→ヘルスチェック200 まで完走を確認済み。
- **旧DBの後始末（2026-07-25 確認）**: Render ダッシュボードに残っていた `rhythm-raiders-db` が「Free database expired / 4日後に削除」を表示。Service ID `dpg-d8nvkd3bc2fs73feqtd0-a` が上記エラーのホスト名と一致することから、**移行前の旧DBの残骸**と確定。`render.yaml` に `databases:` ブロックは無く、Web サービスの `DATABASE_URL` も `sync: false` で Supabase を直接指すため（`fromDatabase` 参照なし）**アプリへの影響は無い**。Upgrade は不要で、放置すれば自動削除される。削除予定は 2026-07-29 頃（期限切れ 07-15 + 14日）。

### 復旧時にハマった点（次回のために）

1. **接続文字列のプレースホルダを置換し忘れる**。`[YOUR-PASSWORD]` を残したまま設定すると `URI::InvalidURIError: bad URI` でRailsが起動前に落ちる。角括弧ごと消してパスワードを書く。パスワードに記号があればパーセントエンコードが必要なので、**英数字のみのパスワードにしておくと事故らない**。
2. **Supavisor のサーキットブレーカー**。認証失敗が続くと `FATAL: (ECIRCUITBREAKER) too many authentication failures` で新規接続が**発信元IP単位で最大2分ブロック**される。`render-start.sh` は `set -e` で落ちるとコンテナが再起動→再試行するため、**間違ったパスワードのままだとブレーカーが再適用され続けて永久に解けない**。まず Render の **Suspend Service** で接続試行を止めること。
3. **ブレーカーはIP単位なので、ローカルから検証できる**。Renderがロックされていても自宅PCからは試せる。Renderを触る前にこれで確定させると速い:
   `docker run --rm postgres:13 psql '<接続文字列>' -c 'select version();'`
4. エラーの読み分け: `Tenant or user not found` = ホスト名/ユーザー名の形式ミス（`aws-0` と `aws-1` の取り違えなど） / `password authentication failed` = ユーザーは特定できておりパスワードのみ誤り。

## 4.7 死んだコードの一掃（2026-07-16）

ドキュメントと実態の突き合わせ中に見つかった「実体の無いもの」を整理した。

- **`Post` モデル一式を削除**。`app/models/post.rb`（作者コメントに `# future: delete`）があるのに `posts` テーブルが存在せず、使えば落ちる状態だった。model / admin・member の各 controller / helper / views / scss をまとめて削除。
  - **ただし単純な削除ではなかった**: 管理画面のコメントモデレーションが `DELETE /admin/posts/:post_id/comments/:id` というルートを流用しており（`post_id` の位置に `created_track` を渡していた）、`posts` を消すと**生きている機能が道連れ**になる。そのため `comments` を正しい親である `created_tracks` 配下へ移設し（`admin_created_track_comment_path`）、`admin/members/show.html.erb` のリンクを差し替えてから削除した。
  - 検証: 管理者ログイン→メンバー詳細に新パスのリンクが出る→削除で `removed_by_admin` が立つ→会員側の楽曲詳細に「運営により削除されました」と表示、までを実際に通して確認。
- **`Notification` の `enum action_type` を削除**。`action_type` カラムが存在せず参照箇所も無かった（呼べば落ちる地雷）。通知の種類は実際には subject の実クラス（Like / PostComment / Relationship）でパーシャルを出し分けている。3種類の通知を発生させ通知一覧が200で描画されることを確認済み。
- **`Gemfile.lock` を Gemfile と同期**。`carrierwave` が Gemfile から撤去済みなのに lock の DEPENDENCIES に残っていた（`--frozen`/`--deployment` では失敗する状態）。`bundle install` で再解決し、差分は `carrierwave` と専用依存 `ssrf_filter` の除去のみ。

## 4.8 投稿済み楽曲の Creator Word 編集（2026-07-25）

投稿後に Word（`creater_word`）を直せないことにユーザーが気づいたため対応した。

- **経緯**: `member/created_tracks#edit` は元々 **AI動画URL専用**の画面で、`creater_word` は投稿フォームにしか無く後から変更できなかった。
- **対応**: edit 画面を「§ Edit Track §」に広げ、**Creator Word（textarea 4行）＋ AI Music Video URL** の2項目にした。strong parameters は `music_video_params` → `track_edit_params` に改名し `:creater_word, :music_video_url` のみ許可。**タイトル・ジャンル・音源ファイルは投稿時のまま変更不可**（音源の差し替えは実質「別の曲」になるため意図的に塞いでいる）。
- **導線のラベル**: 実態と合わなくなったため、楽曲詳細の「AI動画を追加/編集」→ **「楽曲を編集」**、マイページの同ボタン → **「Edit」** に変更。
- **権限**: 既存の `set_own_created_track` がそのまま効くので他人の楽曲は編集画面に入れない。`creater_word` は `presence: true` のため空欄保存はエラーになり編集画面へ戻る。
- **検証**: 2026-07-25、本番（Render）で楽曲詳細に「楽曲を編集」ボタンが出ること、そこから Word を書き換えて保存できることをユーザーが確認済み。
- **追加対応（同日）**: 続けて `music_title` / `music_genre` も編集可能にした。編集画面は Title / Genre / Creator Word / AI動画URL の4項目になり、`track_edit_params` もその4つを許可する。両カラムとも `presence: true` があるため空欄保存はエラーで戻る。
- **`music_file` だけは意図的に編集不可のまま**。音源を差し替えると実質「別の曲」になるのに、いいね・コメントは元の曲に紐づいたまま残り、中身だけすり替わるため。差し替えたい場合は新規投稿してもらう。

### 確認時にハマった点

**「変更が反映されない」の正体は、見ていたのが本番サイトだったこと。** ローカル Docker（localhost:3100）と本番（onrender.com）は別物で、変更はコミット・push するまで本番に出ない。切り分けに使った材料:

- `docker exec <container> grep ... /app/app/views/...` で**コンテナ内のファイル**に変更が届いているか確認（bind mount なので届いていた）
- `log/development.log` の `Started GET` の**最終時刻**を見る → 9日前で止まっており、localhost には誰もアクセスしていないと判明
- 画面に出ていた曲名・ユーザー名がローカルの seed データ（Fantasy World 等 / `test1@example.com`）に無い＝本番データだった

---

## 4.9 AI静止画（ジャケット画像）対応（2026-07-25）

- **背景**: AI動画(MV)機能は Neural Frames が課金の壁で動作確認が進まなかったため、手元の画像ファイルだけで完結する**静止画**も載せられるようにした。
  - なお埋め込み判定は **YouTube / Vimeo のホストとID形式しか見ていない**（`music_video_embed_url`）ので、**MV機能自体は任意のYouTube動画URLで検証できる**。Neural Frames 製である必要はない。
- **方式**: 外部URL貼り付けではなく **ActiveStorage の添付**（`has_one_attached :music_image`）を選択。`profile_image` / `music_file` と同じ仕組みで本番は Supabase Storage に入る。**マイグレーション不要**。ホットリンクやリンク切れの問題も持ち込まない。
- **制約**: PNG / JPEG / GIF / WebP、5MB まで（`IMAGE_CONTENT_TYPES` / `IMAGE_MAX_SIZE`）。任意項目。
- **variant(リサイズ)は使わない**。本番の画像processor依存で `InvariableError` になり得るため、元画像をそのまま `image_tag` に渡し、幅は CSS（`.ts-artwork__frame img`）で制御する。`Member#get_profile_image` と同方針。
- **画面**: 投稿・編集フォームに「AI Artwork（任意）」のファイル欄、楽曲詳細ではプレーヤーの上に表示。編集画面には現在の画像プレビューと「この画像を削除する」チェックボックスを置いた。
- **purge の順序に注意**: 添付を外すのは `update` が**成功してから**。先に purge すると、バリデーションで弾かれた時に画像だけ消える。新しい画像が来ている時は削除指定より差し替えを優先する。

### 検証（ローカル Docker で実施・2026-07-25）

ブラウザ目視ができないため、コンテナ内で実際に動かして確認した。

1. JPEG を添付 → `valid?` = true、保存成功、blob の content_type / byte_size を確認
2. `text/plain` を添付 → バリデーションエラー「PNG / JPEG / GIF / WebP のいずれかを選んでください」
3. `purge` → 添付解除を確認
4. `ActionDispatch::Integration::Session` で会員ログイン（303）→ 楽曲詳細 **200**・"AI Artwork" 見出しと ActiveStorage の `<img>` を確認 → 編集画面 **200**・削除チェックボックスと `multipart/form-data` を確認
5. SCSS 変更を含む **webpack 再コンパイルが通る**ことを確認（`public/packs/manifest.json` が更新された）

---

## 5. 既知の制約・今後の候補

- アップロードは Supabase Storage で永続化済み。ただし **Supabase 無料プロジェクトは約1週間アクセスが無いと一時停止**（次アクセスで復帰）。R2_* 環境変数を外せばローカル保存(非永続)に戻る。
- **画像のWebP化は見送り（2026-06-21 判断）**。理由: 既に mozjpeg 品質85 で -76% 済みで追加効果が小さい一方、全画像のwebp生成＋CSS `url()`/`image_tag` 多数の差し替えが必要でROIが低いため。やるなら「背景のみWebP化（SCSSの url() のみ変更でリスク限定）」が候補。
- 通知の `_comment` パーシャルは中身が空（コメント通知は表示が簡素）。`member_tracks` 等の未到達スキャフォールドが一部残存。
- **楽曲の編集は Title / Genre / Creator Word / AI静止画 / AI動画URL**（§4.8・§4.9）。音源ファイル(`music_file`)の差し替えだけは意図的に塞いでいる（いいね・コメントを保ったまま中身がすり替わるのを防ぐため）。
- AI静止画は**楽曲詳細ページのみ**に表示（§4.9）。一覧・マイページのサムネイル化は未対応（やるなら一覧CSSの調整と、画像なし楽曲との混在の見た目を要検討）。
- ~~旧CarrierWave関連の残置~~ / ~~`Post` モデルの残置~~ → **§4.7 で一掃済み**。
- ローカル開発は Docker デモ構成（`docker-compose.demo.yml`、http://localhost:3100）。`config/master.key`・`.env` は未コミット（各自生成）。

---

## デプロイ運用メモ（Render）

- `main` への push で自動再デプロイ。
- **ローカル（http://localhost:3100 ）と本番（onrender.com）は完全に別物**。DBもデータも別で、コード変更は push するまで本番に出ない。「直したのに変わらない」ときは、まずどちらを見ているか確認する（§4.8 の確認時にハマった点）。
- 環境変数: `RAILS_ENV=production` / `RAILS_LOG_TO_STDOUT` / `RAILS_SERVE_STATIC_FILES` / `SECRET_KEY_BASE`(自動生成) / `DATABASE_URL`(Supabase・ダッシュボードで設定) / `ADMIN_EMAIL` / `ADMIN_PASSWORD`(ダッシュボードで設定)。
- seed のデモ会員: `test1@example.com` / `password01`。
- **DB は Supabase Postgres**（§4.6）。`DATABASE_URL` には必ず **Session pooler** の文字列を使う（Direct connection はIPv6専用でRenderから繋がらない）。
- DB を新規に用意し直した場合、起動時の `db:prepare` + `db:seed` でスキーマとデモデータが自動で入る（手動マイグレーション不要）。
