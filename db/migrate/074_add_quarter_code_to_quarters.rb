class AddQuarterCodeToQuarters < ActiveRecord::Migration
  def self.up
    add_column :quarters, :quarter_code_id, :integer
    remove_column :quarters, :quarter
  end

  def self.down
    remove_column :quarters, :quarter_code_id
    add_column :quarters, :quarter, :string
  end
end
