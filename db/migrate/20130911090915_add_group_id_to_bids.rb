class AddGroupIdToBids < ActiveRecord::Migration
  def change
    add_column :bids, :group_id, :integer
  end
end
