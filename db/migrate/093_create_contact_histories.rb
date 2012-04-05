class CreateContactHistories < ActiveRecord::Migration
  def self.up
    create_table :contact_histories do |t|
      t.integer :person_id
      t.text :type
      t.text :email

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_histories
  end
end
