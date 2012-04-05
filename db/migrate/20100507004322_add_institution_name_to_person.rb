class AddInstitutionNameToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :institution_name, :string
  end

  def self.down
    remove_column :people, :institution_name
  end
end
