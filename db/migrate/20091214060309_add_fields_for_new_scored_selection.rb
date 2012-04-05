class AddFieldsForNewScoredSelection < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :application_final_decision_type_id, :integer
    add_column :offerings, :award_basis, :string
    add_column :application_for_offerings, :final_committee_notes, :text
    add_column :offerings, :final_decision_weight_ratio, :float
    
    create_table :application_final_decision_types, :force => true do |t|
      t.string :title
      t.integer :application_status_type_id
      t.boolean :yes_option
      t.integer :offering_id
      t.integer :creator_id
      t.integer :updater_id
      t.integer :deleter_id
      t.timestamps
    end
  end

  def self.down
    drop_table :application_final_decision_types
    remove_column :offerings, :final_decision_weight_ratio
    remove_column :application_for_offerings, :final_committee_notes
    remove_column :offerings, :award_basis
    remove_column :application_for_offerings, :application_final_decision_type_id
  end
end
