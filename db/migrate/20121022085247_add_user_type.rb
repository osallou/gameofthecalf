class AddUserType < ActiveRecord::Migration
  def change
    add_column :users, :usertype, :string, :default => User::STUDENT
  end

end
