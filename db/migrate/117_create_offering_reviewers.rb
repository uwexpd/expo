class CreateOfferingReviewers < ActiveRecord::Migration
  def self.up
    create_table :offering_reviewers do |t|
      t.integer :person_id
      t.integer :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_reviewers
  end
end
