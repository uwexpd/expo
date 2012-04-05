class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :firstname, :string
      t.column :lastname, :string
      t.column :type, :string
    end
  end

  def self.down
    drop_table :people
  end
end