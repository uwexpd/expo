class AddSchoolTypeTable < ActiveRecord::Migration
  def self.up
    create_table :school_types do |t|
      t.string :name
    end
    
    add_column :organizations, :school_type_id, :integer
  end

  def self.down
    drop_table :school_types
    
    remove_column :organizations, :school_type_id
  end
end
