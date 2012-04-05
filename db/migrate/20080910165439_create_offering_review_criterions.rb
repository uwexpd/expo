class CreateOfferingReviewCriterions < ActiveRecord::Migration
  def self.up
    create_table :offering_review_criterions do |t|
      t.integer :offering_id
      t.string :title
      t.integer :max_score

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_review_criterions
  end
end
