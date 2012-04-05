class CreateOfferingAdminPhaseTasks < ActiveRecord::Migration
  def self.up
    create_table :offering_admin_phase_tasks do |t|
      t.integer :offering_admin_phase_id
      t.string :title
      t.boolean :complete
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_admin_phase_tasks
  end
end
