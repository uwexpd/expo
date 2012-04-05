class AddAwardedBooleansToApplicationForOfferings < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :awarded, :boolean
    add_column :application_for_offerings, :contingency, :boolean
    add_column :application_for_offerings, :not_awarded, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :not_awarded
    remove_column :application_for_offerings, :contingency
    remove_column :application_for_offerings, :awarded
  end
end
