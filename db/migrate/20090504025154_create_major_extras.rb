class CreateMajorExtras < ActiveRecord::Migration
  def self.up
    create_table :major_extras do |t|
      t.integer :major_branch
      t.integer :major_pathway
      t.integer :major_last_yr
      t.integer :major_last_qtr
      t.string :major_abbr
      t.string :fixed_name

      t.timestamps
    end
  end

  def self.down
    drop_table :major_extras
  end
end
