class AddDisbursementTrackingFieldsToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :awarded_at, :datetime
    add_column :application_for_offerings, :approved_at, :datetime
    add_column :application_for_offerings, :financial_aid_approved_at, :datetime
    add_column :application_for_offerings, :disbursed_at, :datetime
    add_column :application_for_offerings, :closed_at, :datetime
  end

  def self.down
    remove_column :application_for_offerings, :closed_at
    remove_column :application_for_offerings, :disbursed_at
    remove_column :application_for_offerings, :financial_aid_approved_at
    remove_column :application_for_offerings, :approved_at
    remove_column :application_for_offerings, :awarded_at
  end
end
