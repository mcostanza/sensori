class CreateTracks < ActiveRecord::Migration

  def up
    create_table :tracks do |t|
      t.integer :soundcloud_id, :null => false
      t.integer :member_id, :null => false
      t.string :title, :null => false
      t.string :permalink_url, :null => false
      t.string :stream_url, :null => false
      t.datetime :posted_at, :null => false
      t.string :artwork_url, :null => false

      t.foreign_key :members

      t.timestamps
    end
  end

  def down
    remove_foreign_key(:tracks, :members)
    drop_table :tracks
  end
end
