class AddDisbersementTypeToApplicationAwards < ActiveRecord::Migration
  def self.up
    add_column :application_awards, :disbersement_type_id, :integer
  end

  def self.down
    remove_column :application_awards, :disbersement_type_id
  end
end
