class AddNameFieldsToApplicationGroupMember < ActiveRecord::Migration
  def self.up
    add_column :application_group_members, :firstname, :string
    add_column :application_group_members, :lastname, :string
    add_column :application_group_members, :uw_student, :boolean
    add_column :application_group_members, :verification_email_sent_at, :datetime
  end

  def self.down
    remove_column :application_group_members, :verification_email_sent_at
    remove_column :application_group_members, :uw_student
    remove_column :application_group_members, :lastname
    remove_column :application_group_members, :firstname
  end
end
