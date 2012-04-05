class AddShowPermanentInactiveOptionToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :show_permanently_inactive_option, :boolean
    add_column :committees, :ask_for_replacement, :boolean
  end

  def self.down
    remove_column :committees, :ask_for_replacement
    remove_column :committees, :show_permanently_inactive_option
  end
end
