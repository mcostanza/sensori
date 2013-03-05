class Usernames < ActiveRecord::Migration
  def up
    add_column :users, :username, :string
    
    add_index :users, :username
  end

  def down
    remove_column :users, :username
  end
end
