class AddFakeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fake, :integer, :default => 0
  end
end
