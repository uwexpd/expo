class ChangeStaffContactPersonToStaffContactUserInOrganizationQuarters < ActiveRecord::Migration
  def self.up
    rename_column :organization_quarters, :staff_contact_person_id, :staff_contact_user_id
  end

  def self.down
    rename_column :organization_quarters, :staff_contact_user_id, :staff_contact_person_id
  end
end
