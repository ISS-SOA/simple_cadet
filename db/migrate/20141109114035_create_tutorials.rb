class CreateTutorials < ActiveRecord::Migration
  def self.up
    create_table :tutorials do |t|
      t.string :description
      t.text :usernames
      t.text :badges
      t.timestamps
    end
  end

  def self.down
    drop_table :tutorials
  end
end
