class CreateOfferingInterviewerConflictOfInterests < ActiveRecord::Migration
  def self.up
    create_table :offering_interviewer_conflict_of_interests do |t|
      t.integer :offering_interviewer_id
      t.integer :application_for_offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_interviewer_conflict_of_interests
  end
end
