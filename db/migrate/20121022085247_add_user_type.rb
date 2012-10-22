class AddUserType < ActiveRecord::Migration
  def change
    add_column :users, :usertype, :integer, :default => User::STUDENT
  end

end
