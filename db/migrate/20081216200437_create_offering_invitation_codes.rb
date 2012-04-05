class CreateOfferingInvitationCodes < ActiveRecord::Migration
  def self.up
    create_table :offering_invitation_codes do |t|
      t.integer :offering_id
      t.string :code
      t.integer :application_for_offering_id
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_invitation_codes
  end
end
