class AddBandcampAlbumIdToSessions < ActiveRecord::Migration
  def change
  	add_column :sessions, :bandcamp_album_id, :integer
  end
end
