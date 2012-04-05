class AddCategoryToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :category, :string
  end

  def self.down
    remove_column :notes, :category
  end
end
