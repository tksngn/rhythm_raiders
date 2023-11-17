class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.references :member, foreign_key: true
      t.string :post_comment, null: false

      t.timestamps
    end
  end
end
