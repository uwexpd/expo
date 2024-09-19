class AddConfirmPrimaryToDeletedApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :deleted_application_mentors, :confirm_primary, :boolean
  end

  def self.down
    remove_column :deleted_application_mentors, :confirm_primary
  end
end
