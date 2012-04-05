class CreateApplicationTexts < ActiveRecord::Migration
  def self.up
    create_table :application_texts do |t|
      t.integer :application_for_offering_id
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :application_texts
  end
end
