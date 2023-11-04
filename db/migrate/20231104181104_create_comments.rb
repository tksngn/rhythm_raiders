class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.string :comment_content, null: false

      t.timestamps
    end
  end
end
