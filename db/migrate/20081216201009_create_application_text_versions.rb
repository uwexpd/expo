class CreateApplicationTextVersions < ActiveRecord::Migration
  def self.up
    create_table :application_text_versions do |t|
      t.integer :application_text_id
      t.text :text
      t.text :comments
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :application_text_versions
  end
end
