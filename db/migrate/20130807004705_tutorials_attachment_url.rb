class TutorialsAttachmentUrl < ActiveRecord::Migration
  def up
  	remove_column :tutorials, :attachment
  	add_column :tutorials, :attachment_url, :string
  end

  def down
  	remove_column :tutorials, :attachment_url
  	add_column :tutorials, :attachment_url
  end
end
