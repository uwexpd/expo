class AddScholarTitleToAwardType < ActiveRecord::Migration
  def self.up
    add_column :award_types, :scholar_title, :string
  end

  def self.down
    remove_column :award_types, :scholar_title
  end
end
