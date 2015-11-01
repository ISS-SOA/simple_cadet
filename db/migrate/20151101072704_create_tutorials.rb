class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.string :description
      t.text :usernames
      t.text :badges
      t.timestamps null:false
    end
  end
end
