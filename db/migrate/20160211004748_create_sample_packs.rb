class CreateSamplePacks < ActiveRecord::Migration
  def change
    create_table :sample_packs do |t|
      t.string :url
      t.string :name
      t.integer :session_id
      t.boolean :deleted, default: false

      t.timestamps
    end

    add_index :sample_packs, :url
  end
end
