class SoundcloudIndexes < ActiveRecord::Migration
  def up
    add_index :members, :soundcloud_id
    add_index :tracks, :soundcloud_id
  end

  def down
    remove_index :members, :soundcloud_id
    remove_index :tracks, :soundcloud_id
  end
end
