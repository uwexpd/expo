class AddUnitSignatureToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :unit_signature, :text
  end

  def self.down
    remove_column :committees, :unit_signature
  end
end
