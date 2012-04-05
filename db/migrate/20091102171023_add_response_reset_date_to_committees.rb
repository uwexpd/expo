class AddResponseResetDateToCommittees < ActiveRecord::Migration
  def self.up
    add_column :committees, :response_reset_date, :date
  end

  def self.down
    remove_column :committees, :response_reset_date
  end
end
