class CreateSessions < ActiveRecord::Migration
  def up
    create_table :sessions do |t|
      t.string :title, :null => false
      t.text :description, :null => false
      t.string :image, :null => false
      t.datetime :end_date, :null => false
      t.string :facebook_event_id
      t.string :attachment
      t.string :slug, :null => false
      t.integer :member_id, :null => false
      t.timestamps

      t.foreign_key :members
    end
  end

  def down
    remove_foreign_key(:sessions, :members)
    drop_table :sessions
  end
end
