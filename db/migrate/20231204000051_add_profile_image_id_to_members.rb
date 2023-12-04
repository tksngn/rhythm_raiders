class AddProfileImageIdToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :profile_image_id, :string
  end
end
