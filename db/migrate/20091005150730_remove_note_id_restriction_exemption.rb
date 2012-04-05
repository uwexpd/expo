class RemoveNoteIdRestrictionExemption < ActiveRecord::Migration
  def self.up
    remove_column :offering_restriction_exemptions, :note_id
  end

  def self.down
	add_column :offering_restriction_exemptions, :note_id, :integer
  end
end