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

CreatedTrack.find_or_create_by!(music_title: "Fantasy World") do |created_track|
  created_track.music_genre = "Orchestra"
  created_track.music_file = File.open("#{Rails.root}/db/fixtures/fantasy-background-music-110593.mp3")
  created_track.creater_word = "壮大な感じの素晴らしい曲に仕上がりました！"
  created_track.member = Test01
end

CreatedTrack.find_or_create_by!(music_title: "Medieval Cityscape") do |created_track|
  created_track.music_genre = "Medieval BGM"
  created_track.music_file = File.open("#{Rails.root}/db/fixtures/field.mp3")
  created_track.creater_word = "中世の街並みを表現できるいい曲になりました！"
  created_track.member = Test02
end

CreatedTrack.find_or_create_by!(music_title: "Turmoil of Battle") do |created_track|
  created_track.music_genre = "Battle BGM"
  created_track.music_file = File.open("#{Rails.root}/db/fixtures/worldsend.mp3")
  created_track.creater_word = "激しい戦いの火蓋が切って落とされました！"
  created_track.member = Test03
end

puts "seedの実行が完了しました"