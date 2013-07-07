class FeaturedTutorials < ActiveRecord::Migration
  def up
    add_column :tutorials, :featured, :boolean, :default => false
  end

  def down
    remove_column :tutorials, :featured
  end
end
