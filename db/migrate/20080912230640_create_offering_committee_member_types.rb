class CreateOfferingCommitteeMemberTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_committee_member_types do |t|
      t.integer :offering_id
      t.integer :committee_member_type_id
      t.integer :min_per_applicant
      t.integer :max_applicants_per

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_committee_member_types
  end
end
