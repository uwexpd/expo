class AddFerpaReminderDateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :ferpa_reminder_date, :datetime
  end

  def self.down
    remove_column :users, :ferpa_reminder_date
  end
end
