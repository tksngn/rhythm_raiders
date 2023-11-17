class AddPostedMemberNameToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :posted_member_name, :string
  end
end
