class AddRegIdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :reg_id, :string
  end

  def self.down
    remove_column :people, :reg_id
  end
end
