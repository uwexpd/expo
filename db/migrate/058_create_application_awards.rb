class CreateApplicationAwards < ActiveRecord::Migration
  def self.up
    create_table :application_awards do |t|
      t.integer :application_for_offering_id
      t.integer :quarter_id
      t.float   :amount_requested
      t.string  :amount_requested_notes
      t.float   :amount_approved
      t.string  :amount_approved_notes
      t.integer :amount_approved_user_id
      t.float   :amount_awarded
      t.string  :amount_awarded_notes
      t.integer :amount_awarded_user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :application_awards
  end
end
