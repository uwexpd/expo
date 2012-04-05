class AddQuarterOfferedToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :quarter_offered_id, :integer
  end

  def self.down
    remove_column :offerings, :quarter_offered_id
  end
end
