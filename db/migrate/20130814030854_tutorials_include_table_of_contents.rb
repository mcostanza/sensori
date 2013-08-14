class TutorialsIncludeTableOfContents < ActiveRecord::Migration
  def up
  	add_column :tutorials, :include_table_of_contents, :boolean, :default => false
  end

  def down
  	remove_column :tutorials, :include_table_of_contents
  end
end
