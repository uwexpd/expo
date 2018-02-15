class AddHideAbstractToDeletedApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :deleted_application_for_offerings, :hide_proceeding_abstract, :boolean
  end

  def self.down
    remove_column :deleted_application_for_offerings, :hide_proceeding_abstract
  end
end
