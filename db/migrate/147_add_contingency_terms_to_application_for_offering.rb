class AddContingencyTermsToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :contingency_terms, :text
  end

  def self.down
    remove_column :application_for_offerings, :contingency_terms
  end
end
