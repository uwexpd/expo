class AddUnitIdToEvaluationQuestion < ActiveRecord::Migration
  def self.up
    add_column :evaluation_questions, :unit_id, :integer
  end

  def self.down
    remove_column :evaluation_questions, :unit_id
  end
end
