class AddFieldsToApplicationForOffering < ActiveRecord::Migration
  def self.up
    
    # add columns for application
    add_column :application_for_offerings, :selection_committee_access_ok, :boolean
    add_column :application_for_offerings, :mentor_access_ok, :boolean
    add_column :application_for_offerings, :local_or_permanent_address, :string
    add_column :application_for_offerings, :project_title, :string
    add_column :application_for_offerings, :project_description, :text
    add_column :application_for_offerings, :hours_per_week, :float
    add_column :application_for_offerings, :how_did_you_hear_id, :integer
    add_column :application_for_offerings, :electronic_signature, :string
    add_column :application_for_offerings, :electronic_signature_date, :date
    add_column :application_for_offerings, :special_notes, :text
    add_column :application_for_offerings, :current_page_id, :integer

    # add some people columns
    add_column :people, :est_grad_qtr, :integer
    add_column :people, :nickname, :string
  
  end

  def self.down
    remove_column :application_for_offerings, :selection_committee_access_ok
    remove_column :application_for_offerings, :mentor_access_ok
    remove_column :application_for_offerings, :local_or_permanent_address
    remove_column :application_for_offerings, :project_title
    remove_column :application_for_offerings, :project_description
    remove_column :application_for_offerings, :hours_per_week
    remove_column :application_for_offerings, :how_did_you_hear
    remove_column :application_for_offerings, :electronic_signature
    remove_column :application_for_offerings, :electronic_signature_date
    remove_column :application_for_offerings, :special_notes
    remove_column :application_for_offerings, :current_page_id
    
    remove_column :people, :est_grad_qtr
    remove_column :people, :nickname
    
  end
end
