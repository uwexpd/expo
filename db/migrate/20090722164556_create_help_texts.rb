class CreateHelpTexts < ActiveRecord::Migration
  def self.up
    create_table :help_texts do |t|
      t.string :type
      t.string :key
      t.string :object_type
      t.string :attribute_name
      t.text :caption
      t.text :example
      t.integer :creator_id
      t.integer :updater_id
      t.timestamps
      t.text :tech_note
      t.string :title
    end
  end

  def self.down
    drop_table :help_texts
  end
end
