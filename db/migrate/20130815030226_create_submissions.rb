class CreateSubmissions < ActiveRecord::Migration
  def up
    create_table :submissions do |t|
      t.integer :session_id, :null => false
      t.string :title, :null => false
      t.integer :member_id, :null => false
      t.string :attachment_url, :null => false

      t.foreign_key :members

      t.timestamps
    end
  end

  def down
  	remove_foreign_key :submissions, :members
  	drop_table :submissions
  end
end