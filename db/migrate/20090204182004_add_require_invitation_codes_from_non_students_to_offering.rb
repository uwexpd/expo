class AddRequireInvitationCodesFromNonStudentsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :require_invitation_codes_from_non_students, :boolean
  end

  def self.down
    remove_column :offerings, :require_invitation_codes_from_non_students
  end
end
