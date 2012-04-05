class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.string :key
      t.string :quotable_type
      t.integer :quotable_id
      t.text :quote
      t.string :author
      t.string :author_title
      t.string :picture

      t.timestamps
    end
  end

  def self.down
    drop_table :quotes
  end
end
