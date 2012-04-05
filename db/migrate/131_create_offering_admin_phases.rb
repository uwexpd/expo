class CreateOfferingAdminPhases < ActiveRecord::Migration
  def self.up
    create_table :offering_admin_phases do |t|
      t.string :name
      t.string :display_as
      t.integer :offering_id
      t.integer :sequence
      t.boolean :complete

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_admin_phases
  end
end
