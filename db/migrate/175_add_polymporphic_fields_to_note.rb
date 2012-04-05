class AddPolymporphicFieldsToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :private, :boolean
    add_column :notes, :personal, :boolean
    add_column :notes, :contact_type_id, :integer
    add_column :notes, :notable_id, :integer
    add_column :notes, :notable_type, :string
    remove_column :notes, :user_id
  end

  def self.down
    add_column :notes, :user_id, :integer
    remove_column :notes, :notable_type
    remove_column :notes, :notable_id
    remove_column :notes, :contact_type_id
    remove_column :notes, :personal
    remove_column :notes, :private
  end
end
