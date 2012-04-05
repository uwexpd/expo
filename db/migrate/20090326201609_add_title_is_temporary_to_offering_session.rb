class AddTitleIsTemporaryToOfferingSession < ActiveRecord::Migration
  def self.up
    add_column :offering_sessions, :title_is_temporary, :boolean
  end

  def self.down
    remove_column :offering_sessions, :title_is_temporary
  end
end
