class AddAlternateWelcomePageTitleToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :alternate_welcome_page_title, :string
  end

  def self.down
    remove_column :offerings, :alternate_welcome_page_title
  end
end
