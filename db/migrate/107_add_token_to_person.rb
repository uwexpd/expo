class AddTokenToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :token, :string
  end

  def self.down
    remove_column :people, :token
  end
end
