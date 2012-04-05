class CreateEventTypes < ActiveRecord::Migration
  def self.up
    create_table :event_types do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
	add_column :events, :event_type_id, :integer
  end

  def self.down
    drop_table :event_types
	remove_column :events, :event_type_id
  end
end