class AddDisableConfirmationToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :disable_confirmation, :boolean
  end

  def self.down
    remove_column :offerings, :disable_confirmation
  end
end
