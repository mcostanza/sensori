class DeletePrelaunchSignups < ActiveRecord::Migration
  def up
    drop_table :prelaunch_signups
  end

  def down
    create_table :prelaunch_signups do |t|
      t.string :email

      t.timestamps
    end
  end
end
