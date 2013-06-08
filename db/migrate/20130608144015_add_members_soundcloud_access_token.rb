class AddMembersSoundcloudAccessToken < ActiveRecord::Migration
  def up
    add_column :members, :soundcloud_access_token, :string
  end

  def down
    remove_column :members, :soundcloud_access_token
  end
end
