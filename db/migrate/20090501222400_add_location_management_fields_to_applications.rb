class AddLocationManagementFieldsToApplications < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :location_section_id, :integer
    add_column :application_for_offerings, :easel_number, :integer
    add_column :offering_sessions, :offering_application_type_id, :integer
    add_column :offering_sessions, :session_group, :string
    create_table :offering_location_sections, :force => true do |t|
      t.integer :offering_id
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :offering_location_sections
    remove_column :offering_sessions, :session_group
    remove_column :offering_sessions, :offering_application_type_id
    remove_column :application_for_offerings, :easel_number
    remove_column :application_for_offerings, :location_section_id
  end
end
