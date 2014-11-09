class CreateTutorials < ActiveRecord::Migration
  def self.up
    create_table :tuturials do |t|
      t.string :name
      t.text :usernames
      t.text :badges
      t.timestamps
    end
  end

  def self.down
    drop_table :tutorials
  end
end
