class SessionsAttachmentUrl < ActiveRecord::Migration
  def up
    remove_column :sessions, :attachment
    add_column :sessions, :attachment_url, :string
  end

  def down
    remove_column :sessions, :attachment_url
    add_column :sessions, :attachment, :string
  end
end
