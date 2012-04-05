class CreateAdminInterviews < ActiveRecord::Migration
  def self.up
    create_table :admin_interviews do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_interviews
  end
end
