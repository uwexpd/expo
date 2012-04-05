class AddAmountDisbersedToApplicationAwards < ActiveRecord::Migration
  def self.up
    add_column :application_awards, :amount_disbersed, :float
    add_column :application_awards, :amount_disbersed_notes, :string
    add_column :application_awards, :amount_disbersed_user_id, :integer
  end

  def self.down
    remove_column :application_awards, :amount_disbersed
    remove_column :application_awards, :amount_disbersed_notes
    remove_column :application_awards, :amount_disbersed_user_id
  end
end
