class CreateDisbersementTypes < ActiveRecord::Migration
  def self.up
    create_table :disbersement_types do |t|
      t.string  :name
      t.timestamps
    end
  end

  def self.down
    drop_table :disbersement_types
  end
end
