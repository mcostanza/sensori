class DiscussionLastPostAtIndex < ActiveRecord::Migration
  def up
  	add_index :discussions, :last_post_at
  end

  def down
  	remove_index :discussions, :last_post_at
  end
end
