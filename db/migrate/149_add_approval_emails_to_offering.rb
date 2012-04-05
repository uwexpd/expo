class AddApprovalEmailsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :dean_approver_id, :integer
    add_column :offerings, :financial_aid_approver_id, :integer
    add_column :offerings, :disbersement_approver_id, :integer
  end

  def self.down
    remove_column :offerings, :disbersement_approver_id
    remove_column :offerings, :financial_aid_approver_id
    remove_column :offerings, :dean_approver_id
  end
end
