class AddNotesToEvaluationResponse < ActiveRecord::Migration
  def self.up
    add_column :evaluation_responses, :notes, :text
  end

  def self.down
    remove_column :evaluation_responses, :notes
  end
end
