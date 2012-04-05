class CreateOfferingStatuses < ActiveRecord::Migration
  def self.up
    create_table :offering_statuses do |t|
      t.integer :offering_id
      t.integer :application_status_id
      t.text :message
      t.string :public_title

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_statuses
  end
end
