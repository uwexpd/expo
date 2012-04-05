class AddDateYearToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :start_year, :integer
    add_column :offering_questions, :end_year, :integer
  end

  def self.down
    remove_column :offering_questions, :end_year
    remove_column :offering_questions, :start_year
  end
end
