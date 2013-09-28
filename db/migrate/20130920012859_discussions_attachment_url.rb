class DiscussionsAttachmentUrl < ActiveRecord::Migration
  def up
  	add_column :discussions, :attachment_url, :string
  end

  def down
  	remove_column :discussions, :attachment_url
  end
end
