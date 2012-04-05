class CreateOfferingPages < ActiveRecord::Migration
  def self.up
    create_table :offering_pages do |t|
      t.integer :offering_id
      t.string :title
      t.string :description
      t.integer :ordering

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_pages
  end
end
