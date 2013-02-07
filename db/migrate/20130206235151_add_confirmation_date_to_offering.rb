class AddConfirmationDateToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :confirmation_deadline, :datetime
  end

  def self.down
    remove_column :offerings, :confirmation_deadline
  end
end
