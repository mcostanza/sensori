class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.string :title
      t.text :description
      t.text :body
      t.string :slug
      t.integer :member_id
      t.string :video_url
      t.string :attachment_url

      t.timestamps
    end
  end
end
