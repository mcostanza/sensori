class ChangeDiscussionsLastResponseAt < ActiveRecord::Migration
  def up
  	rename_column :discussions, :last_response_at, :last_post_at
  end

  def down
  	rename_column :discussions, :last_post_at, :last_response_at
  end
end
