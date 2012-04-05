class CreateActivityTypes < ActiveRecord::Migration
  def self.up
    create_table :activity_types, :force => true do |t|
      t.string :title
      t.string :abbreviation
      t.timestamps
    end
  end

  def self.down
    drop_table :activity_types
  end
end
