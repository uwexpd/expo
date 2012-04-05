class AddPublicAndAllowMultipleStaffToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :public, :boolean
    add_column :events, :allow_multiple_positions_per_staff, :boolean
    add_column :events, :staff_signup_email_template_id, :integer
  end

  def self.down
    remove_column :events, :staff_signup_email_template_id
    remove_column :events, :allow_multiple_positions_per_staff
    remove_column :events, :public
  end
end
