class ChangeSessionsBandcampPlaylistIdToString < ActiveRecord::Migration
  def up
    change_column :sessions, :bandcamp_album_id, :string
  end

  def down
    change_column :sessions, :bandcamp_album_id, :integer
  end
end