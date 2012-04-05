class CreateQuarterCodes < ActiveRecord::Migration
  def self.up
    create_table :quarter_codes do |t|
      t.string :abbreviation
      t.string :name
    end
  end

  def self.down
    drop_table :quarter_codes
  end
end
