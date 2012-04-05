class FixOfferingRestrictions < ActiveRecord::Migration
  def self.up
    remove_column :offering_restrictions, :offering_restriction_type_id
    add_column :offering_restrictions, :type, :string
    add_column :offering_restrictions, :extra_detail, :text
    
    drop_table :offering_restriction_types
    
  end

  def self.down
    add_column :offering_restrictions, :offering_restriction_type_id, :integer
    remove_column :offering_restrictions, :type
    remove_column :table_name, :extra_detail
    
    create_table "offering_restriction_types", :force => true do |t|
      t.string   "name"
      t.string   "description"
      t.text     "error_message"
      t.string   "method_to_call"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
