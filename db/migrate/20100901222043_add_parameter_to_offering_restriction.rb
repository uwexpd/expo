class AddParameterToOfferingRestriction < ActiveRecord::Migration
  def self.up
    add_column :offering_restrictions, :parameter, :text
  end

  def self.down
    remove_column :offering_restrictions, :parameter
  end
end
