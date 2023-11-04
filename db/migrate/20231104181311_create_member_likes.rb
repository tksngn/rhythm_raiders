class CreateMemberLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :member_likes do |t|

      t.timestamps
    end
  end
end
