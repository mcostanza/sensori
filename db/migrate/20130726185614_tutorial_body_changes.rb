class TutorialBodyChanges < ActiveRecord::Migration
  def up
    rename_column :tutorials, :body, :body_html
    add_column :tutorials, :body_components, :text
    add_column :tutorials, :published, :boolean, :default => false
  end

  def down
    rename_column :tutorials, :body_html, :body
    remove_column :tutorials, :body_components
    remove_column :tutorials, :published
  end
end
