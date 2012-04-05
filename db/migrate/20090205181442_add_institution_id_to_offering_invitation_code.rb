class AddInstitutionIdToOfferingInvitationCode < ActiveRecord::Migration
  def self.up
    add_column :offering_invitation_codes, :institution_id, :integer
  end

  def self.down
    remove_column :offering_invitation_codes, :institution_id
  end
end
