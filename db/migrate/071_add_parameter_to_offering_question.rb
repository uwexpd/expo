class AddParameterToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :parameter1, :string
  end

  def self.down
    remove_column :offering_questions, :parameter1
  end
end
