class AddFinancialAidApprovalRequestSentAtToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :financial_aid_approval_request_sent_at, :datetime
  end

  def self.down
    remove_column :offerings, :financial_aid_approval_request_sent_at
  end
end
