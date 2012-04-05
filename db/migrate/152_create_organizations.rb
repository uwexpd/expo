class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string :name
      t.integer :default_location_id
      t.integer :parent_organization_id
      t.string :mailing_line_1
      t.string :mailing_line_2
      t.string :mailing_city
      t.string :mailing_state
      t.string :mailing_zip
      t.string :website_url
      t.string :main_phone
      t.text :mission_statement
      t.boolean :approved

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
