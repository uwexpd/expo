class AddCompleterFieldsToEvaluation < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :completer_person_id, :integer
    add_column :evaluations, :completer_name, :string
    add_column :evaluations, :completer_reason, :text
  end

  def self.down
    remove_column :evaluations, :completer_reason
    remove_column :evaluations, :completer_name
    remove_column :evaluations, :completer_person_id
  end
end
