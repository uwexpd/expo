class CreateApplicationPages < ActiveRecord::Migration
  def self.up
    create_table :application_pages do |t|
      t.integer :application_for_offering_id
      t.integer :offering_page_id
      t.boolean :complete
      t.boolean :started
      t.boolean :passed_validations

      t.timestamps
    end
  end

  def self.down
    drop_table :application_pages
  end
end
