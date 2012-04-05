class CreateOfferingStatusEmails < ActiveRecord::Migration
  def self.up
    create_table :offering_status_emails do |t|
      t.integer :offering_status_id
      t.integer :email_template_id
      t.boolean :auto_send
      t.string :send_to

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_status_emails
  end
end
