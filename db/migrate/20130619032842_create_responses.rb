class CreateResponses < ActiveRecord::Migration
  def up
    create_table :responses do |t|
      t.integer :discussion_id, :null => false
      t.text :body, :null => false
      t.text :body_html, :null => false
      t.integer :member_id, :null => false
      t.timestamps

      t.foreign_key :discussions
      t.foreign_key :members
    end
  end

  def down
    remove_foreign_key(:responses, :members)
    remove_foreign_key(:responses, :discussions)
    drop_table :responses
  end
end
