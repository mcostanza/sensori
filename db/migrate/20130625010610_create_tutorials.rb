class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.string :title
      t.text :description
      t.text :body
      t.string :slug
      t.integer :member_id
      t.string :youtube_id
      t.string :attachment

      t.timestamps
    end
  end
end
