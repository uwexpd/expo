class AddFaxToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :fax, :string
  end

  def self.down
    remove_column :people, :fax
  end
end
