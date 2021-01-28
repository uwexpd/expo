class AddVirtualProceedingToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :virtual_proceeding, :boolean
    add_column :offerings, :proceeding_public_display_at, :datetime
  end

  def self.down
    remove_column :offerings, :virtual_proceeding
    remove_column :offerings, :proceeding_public_display_at
  end
end
