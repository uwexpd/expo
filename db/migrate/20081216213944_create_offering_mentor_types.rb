class CreateOfferingMentorTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_mentor_types do |t|
      t.integer :offering_id
      t.integer :application_mentor_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_mentor_types
  end
end
