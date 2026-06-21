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

## 5. 既知の制約・今後の候補

- アップロードは Supabase Storage で永続化済み。ただし **Supabase 無料プロジェクトは約1週間アクセスが無いと一時停止**（次アクセスで復帰）。R2_* 環境変数を外せばローカル保存(非永続)に戻る。
- **画像のWebP化は見送り（2026-06-21 判断）**。理由: 既に mozjpeg 品質85 で -76% 済みで追加効果が小さい一方、全画像のwebp生成＋CSS `url()`/`image_tag` 多数の差し替えが必要でROIが低いため。やるなら「背景のみWebP化（SCSSの url() のみ変更でリスク限定）」が候補。
- 通知の `_comment` パーシャルは中身が空（コメント通知は表示が簡素）。`member_tracks`/`member/posts` 等の未到達スキャフォールドが一部残存（ルート未定義・UI未リンクのため実害なし）。
- 旧CarrierWave関連（`carrierwave` gem / `AudiofileUploader`）は未使用のまま残置（実害なし。整理は任意）。
- ローカル開発は Docker デモ構成（`docker-compose.demo.yml`、http://localhost:3100）。`config/master.key`・`.env` は未コミット（各自生成）。

---

## デプロイ運用メモ（Render）

- `main` への push で自動再デプロイ。
- 環境変数: `RAILS_ENV=production` / `RAILS_LOG_TO_STDOUT` / `RAILS_SERVE_STATIC_FILES` / `SECRET_KEY_BASE`(自動生成) / `DATABASE_URL`(Postgres連携) / `ADMIN_EMAIL` / `ADMIN_PASSWORD`(ダッシュボードで設定)。
- seed のデモ会員: `test1@example.com` / `password01`。
