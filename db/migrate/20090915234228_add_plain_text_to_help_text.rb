class AddPlainTextToHelpText < ActiveRecord::Migration
  def self.up
    add_column :help_texts, :plain_text, :boolean
  end

  def self.down
    remove_column :help_texts, :plain_text
  end
end
