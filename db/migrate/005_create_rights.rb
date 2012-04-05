class CreateRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.column :name, :string
      t.column :controller, :string
      t.column :action, :string
    end
    
    create_table :rights_roles, :id => false do |t|
      t.column :right_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :rights
    drop_table :rights_roles
  end
end
