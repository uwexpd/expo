class AddHideAbstractToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :hide_proceeding_abstract, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :hide_proceeding_abstract
  end
end
