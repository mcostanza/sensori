class AddSoundcloudPlaylistUrlToSessions < ActiveRecord::Migration
  def up
    add_column :sessions, :soundcloud_playlist_url, :string
  end

  def down
    remove_column :sessions, :soundcloud_playlist_url
  end
end
