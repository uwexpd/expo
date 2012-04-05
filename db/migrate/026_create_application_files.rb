class CreateApplicationFiles < ActiveRecord::Migration
  def self.up
    create_table :application_files do |t|
      t.integer :application_for_offering_id
      t.string :title
      t.text :description
      t.integer :uploaded_file_id

      t.timestamps
    end
  end

  def self.down
    drop_table :application_files
  end
end
