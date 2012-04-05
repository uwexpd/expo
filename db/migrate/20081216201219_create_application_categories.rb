class CreateApplicationCategories < ActiveRecord::Migration
  def self.up
    create_table :application_categories do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :application_categories
  end
end
