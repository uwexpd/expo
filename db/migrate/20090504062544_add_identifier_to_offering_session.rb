class AddIdentifierToOfferingSession < ActiveRecord::Migration
  def self.up
    add_column :offering_sessions, :identifier, :string
  end

  def self.down
    remove_column :offering_sessions, :identifier
  end
end
