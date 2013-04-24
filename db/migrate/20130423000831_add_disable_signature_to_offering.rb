class AddDisableSignatureToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :disable_signature, :boolean
  end

  def self.down
    remove_column :offerings, :disable_signature
  end
end
