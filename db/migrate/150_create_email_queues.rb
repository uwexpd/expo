class CreateEmailQueues < ActiveRecord::Migration
  def self.up
    create_table :email_queues do |t|
      t.integer :person_id
      t.text :email
      t.integer :application_status_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :email_queues
  end
end
