class AddValidUntilToOfferingRestrictionExemptions < ActiveRecord::Migration
  def self.up
    add_column :offering_restriction_exemptions, :valid_until, :datetime
  end

  def self.down
    remove_column :offering_restriction_exemptions, :valid_until
  end
end
