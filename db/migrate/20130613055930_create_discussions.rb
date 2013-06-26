class CreateDiscussions < ActiveRecord::Migration
  def up
    create_table :discussions do |t|
      t.string :subject, :null => false
      t.text :body, :null => false
      t.text :body_html, :null => false
      t.string :slug, :null => false
      t.integer :member_id, :null => false
      t.boolean :members_only, :default => false
      t.timestamps

      t.foreign_key :members
    end
  end

  def down
    remove_foreign_key(:discussions, :members)
    drop_table :discussions
  end
end
