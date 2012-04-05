class CreateOfferingApplicationCategories < ActiveRecord::Migration
  def self.up
    create_table :offering_application_categories do |t|
      t.integer :application_category_id
      t.integer :offering_id
      t.text :app_types_allowed

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_application_categories
  end
end
