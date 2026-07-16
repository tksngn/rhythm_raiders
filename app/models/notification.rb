class Notification < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :member

  # NOTE: 通知の種類は subject の実クラス（Like / PostComment / Relationship）で判別し、
  #       同名のパーシャルを出し分けている（member/notifications/index.html.erb）。
  #       以前あった `enum action_type` は notifications に action_type カラムが無く、
  #       参照箇所も無かったため削除した（呼ぶと落ちる状態だった）。
end
