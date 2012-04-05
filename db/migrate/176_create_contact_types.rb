class CreateContactTypes < ActiveRecord::Migration
  def self.up
    create_table :contact_types do |t|
      t.string :title

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :contact_types
  end
end
