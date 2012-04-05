class CreateAccountabilityReports < ActiveRecord::Migration
  def self.up
    create_table :accountability_reports, :force => true do |t|
      t.integer :year
      t.string :quarter_abbrevs
      t.integer :activity_type_id
      t.string :title
      t.boolean :finalized
      t.timestamps
    end
  end

  def self.down
    drop_table :accountability_reports
  end
end
