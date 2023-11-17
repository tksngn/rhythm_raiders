class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :member
  before_save :set_posted_member_name

  private

  def set_posted_member_name
    self.posted_member_name = self.user.name
  end
end