class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :title
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.text :driving_directions
      t.text :bus_directions
      t.text :notes
      t.integer :site_supervisor_person_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :locations
  end
end
