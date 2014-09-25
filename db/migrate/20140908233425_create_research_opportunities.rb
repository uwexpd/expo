class CreateResearchOpportunities < ActiveRecord::Migration
  def self.up
    create_table :research_opportunities do |t|
      t.string :name
      t.string :email
      t.string :department
      t.string :title
      t.text :description
      t.text :requirements
      t.integer :research_area1
      t.integer :research_area2
      t.integer :research_area3
      t.integer :research_area4
      t.date :end_date
      t.boolean :active
      t.boolean :removed
      t.boolean :submitted
            
      t.timestamps
    end
  end

  def self.down
    drop_table :research_opportunities
  end
end
