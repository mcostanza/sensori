class DiscussionResponseStats < ActiveRecord::Migration
  def up
  	add_column :discussions, :response_count, :integer, :default => 0
  	add_column :discussions, :last_response_at, :datetime
  end

  def down
  	remove_column :discussions, :response_count
  	remove_column :discussions, :last_response_at
  end
end
