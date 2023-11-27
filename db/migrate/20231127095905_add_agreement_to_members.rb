class AddAgreementToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :agreement, :boolean
  end
end
