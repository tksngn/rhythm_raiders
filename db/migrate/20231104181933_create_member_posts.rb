class CreateMemberPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :member_posts do |t|

      t.timestamps
    end
  end
end
