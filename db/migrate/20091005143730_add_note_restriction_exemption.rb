class AddNoteRestrictionExemption < ActiveRecord::Migration
  def self.up
    add_column :offering_restriction_exemptions, :note, :text
  end

  def self.down
    remove_column :offering_restriction_exemptions, :note
  end
end