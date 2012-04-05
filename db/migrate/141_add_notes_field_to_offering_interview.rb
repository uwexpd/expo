class AddNotesFieldToOfferingInterview < ActiveRecord::Migration
  def self.up
    add_column :offering_interviews, :notes, :text
  end

  def self.down
    remove_column :offering_interviews, :notes
  end
end
