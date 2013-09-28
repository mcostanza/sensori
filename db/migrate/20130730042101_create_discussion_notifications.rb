class CreateDiscussionNotifications < ActiveRecord::Migration
  def up
    create_table :discussion_notifications do |t|
      t.integer :discussion_id, :null => false
      t.integer :member_id, :null => false
      t.timestamps

      t.foreign_key :discussions
      t.foreign_key :members
    end
  end

  def down
    remove_foreign_key(:discussion_notifications, :members)
    remove_foreign_key(:discussion_notifications, :discussions)
    drop_table :discussion_notifications
  end
end
