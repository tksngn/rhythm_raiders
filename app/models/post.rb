class Post < ApplicationRecord # future: delete
  validates :keyword, format: { with: /\A[a-zA-Z0-9ぁ-んァ-ン一-龥々]+\z/,
    message: "only allows letters, numbers, and Japanese characters" }
end
