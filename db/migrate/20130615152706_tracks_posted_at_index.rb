class TracksPostedAtIndex < ActiveRecord::Migration
  def up
    add_index :tracks, :posted_at
  end

  def down
    remove_index :tracks, :posted_at
  end
end
