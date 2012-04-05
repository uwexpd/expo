class CreateDisciplineCategories < ActiveRecord::Migration
  def self.up
    create_table :discipline_categories do |t|
      t.string :name

      t.timestamps
    end
	add_column :major_extras, :discipline_category_id, :integer
  end

  def self.down
    drop_table :discipline_categories
	remove_column :major_extras, :discipline_category_id
  end
end