class CreateApplicationForOfferings < ActiveRecord::Migration
  def self.up
    create_table :application_for_offerings do |t|
      t.integer :offering_id
      t.integer :person_id
      t.integer :application_status_id

      t.timestamps
    end
  end

  def self.down
    drop_table :application_for_offerings
  end
end
