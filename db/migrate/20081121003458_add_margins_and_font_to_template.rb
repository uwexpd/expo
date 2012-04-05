class AddMarginsAndFontToTemplate < ActiveRecord::Migration
  def self.up
    add_column :templates, :margins, :string
    add_column :templates, :font, :string
  end

  def self.down
    remove_column :templates, :font
    remove_column :templates, :margins
  end
end
