class CreateFeatures < ActiveRecord::Migration
  def up
    create_table :features do |t|
      t.string :title, :null => false
      t.text :description, :null => false
      t.string :image, :null => false
      t.string :link, :null => false
      t.integer :member_id, :null => false
      t.timestamps

      t.foreign_key :members
    end

    def down
      remove_foreign_key(:features, :members)
      drop_table :features
    end
  end
end
