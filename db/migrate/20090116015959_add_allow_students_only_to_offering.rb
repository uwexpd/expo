class AddAllowStudentsOnlyToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :allow_students_only, :boolean
  end

  def self.down
    remove_column :offerings, :allow_students_only
  end
end
