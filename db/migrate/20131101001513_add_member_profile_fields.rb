class AddMemberProfileFields < ActiveRecord::Migration
  def up
    add_column :members, :full_name, :string
    add_column :members, :city, :string
    add_column :members, :country, :string
    add_column :members, :bio, :text
    add_column :members, :bio_html, :text
    add_index :members, :slug
  end

  def down
    remove_index :members, :slug
    remove_column :members, :bio_html
    remove_column :members, :bio
    remove_column :members, :country
    remove_column :members, :city
    remove_column :members, :full_name
  end
end
