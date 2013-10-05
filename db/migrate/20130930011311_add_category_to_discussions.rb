class AddCategoryToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :category, :string
    add_index :discussions, :category
  end

  def down
    remove_column :discussions, :category
  end
end
