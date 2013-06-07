class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :soundcloud_id
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :image_url
      t.boolean :admin, :default => false
      t.string :email

      t.timestamps
    end
  end
end
