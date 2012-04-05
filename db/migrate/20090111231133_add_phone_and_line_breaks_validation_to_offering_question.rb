class AddPhoneAndLineBreaksValidationToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :require_valid_phone_number, :boolean
    add_column :offering_questions, :require_no_line_breaks, :boolean
  end

  def self.down
    remove_column :offering_questions, :require_no_line_breaks
    remove_column :offering_questions, :require_valid_phone_number
  end
end
