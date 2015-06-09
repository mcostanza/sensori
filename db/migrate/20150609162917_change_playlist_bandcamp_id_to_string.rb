class ChangePlaylistBandcampIdToString < ActiveRecord::Migration
  def up
    change_column :playlists, :bandcamp_album_id, :string
  end

  def down
    change_column :playlists, :bandcamp_album_id, :integer
  end
end
