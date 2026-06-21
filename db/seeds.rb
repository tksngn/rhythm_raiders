# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "seedの実行を開始"

Admin.find_or_create_by!(email: ENV['ADMIN_EMAIL']) do |admin|
  admin.password = ENV['ADMIN_PASSWORD']
end

Test01 = Member.find_or_create_by!(email: "test1@example.com") do |member|
  member.password = "password01"
  member.name = "Test01"
  member.creater_name = "tester01"
  member.phone_number = "00000000000"
  member.gender = 0
  member.is_privacy_policy_accepted = true
end

Test02 = Member.find_or_create_by!(email: "test2@example.com") do |member|
  member.password = "password02"
  member.name = "Test02"
  member.creater_name = "tester02"
  member.phone_number = "00000000000"
  member.gender = 0
  member.is_privacy_policy_accepted = true
end

Test03 = Member.find_or_create_by!(email: "test3@example.com") do |member|
  member.password = "password03"
  member.name = "Test03"
  member.creater_name = "tester03"
  member.phone_number = "00000000000"
  member.gender = 0
  member.is_privacy_policy_accepted = true
end

# プロフィール画像(ActiveStorage)の扱い:
#  - R2(永続)使用時: 基本は purge しない（ユーザーがアップした画像を消さない）。
#    ただし旧localストレージ時代の添付(service不一致)は実体が無く404になるので一度だけ掃除。
#  - 非R2(ローカル/非永続)時: 実体が再起動で消えるため従来どおり毎回 purge して作り直す。
using_r2 = Rails.env.production? && ENV['R2_ACCESS_KEY_ID'].present?
current_service = ActiveStorage::Blob.service.name.to_s
Member.find_each do |m|
  next unless m.profile_image.attached?
  if !using_r2
    m.profile_image.purge
  elsif m.profile_image.blob.service_name.to_s != current_service
    m.profile_image.purge
  end
end

# NOTE: 本番(Render)では CarrierWave のアップロードファイル(public/uploads)が
#       デプロイ/再起動ごとに消える一方、DBレコードは Postgres に永続する。
#       find_or_create_by! のブロックはレコード作成時しか走らないため、
#       2回目以降の起動ではファイルだけ欠落して 404 になる。
#       これを避けるため、レコードの有無に関わらず毎回ファイルを登録し直す。
seed_tracks = [
  { title: "Fantasy World",      genre: "Orchestra",    file: "fantasy-background-music-110593.mp3", word: "壮大な感じの素晴らしい曲に仕上がりました！", member: Test01 },
  { title: "Medieval Cityscape", genre: "Medieval BGM", file: "field.mp3",                            word: "中世の街並みを表現できるいい曲になりました！", member: Test02 },
  { title: "Turmoil of Battle",  genre: "Battle BGM",   file: "worldsend.mp3",                        word: "激しい戦いの火蓋が切って落とされました！",     member: Test03 },
]

seed_tracks.each do |t|
  created_track = CreatedTrack.find_or_initialize_by(music_title: t[:title])
  created_track.music_genre  = t[:genre]
  created_track.creater_word = t[:word]
  created_track.member       = t[:member]
  # save! までファイルを開いたままにする（ブロックで閉じるとアップロードに失敗しうる）
  created_track.music_file = File.open("#{Rails.root}/db/fixtures/#{t[:file]}")
  created_track.save!
  puts "  track seeded: #{created_track.music_title} -> #{created_track.music_file.url}"
end

puts "seedの実行が完了しました"