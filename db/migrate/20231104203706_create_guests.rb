class CreateGuests < ActiveRecord::Migration[6.1]
  def change
    create_table :guests do |t|
      t.string :email, null: false, default: ""
      t.string :password, null:false, default: ""

      t.timestamps
    end
  end
end
