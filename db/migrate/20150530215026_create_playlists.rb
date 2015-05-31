class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :title
      t.text :link
      t.integer :bandcamp_album_id
      t.string :soundcloud_uri

      t.timestamps
    end
  end
end
