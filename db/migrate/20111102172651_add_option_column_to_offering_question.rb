class AddOptionColumnToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :option_column, :integer
  end

  def self.down
    remove_column :offering_questions, :option_column
  end
end
