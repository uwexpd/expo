class AddAllowableFieldsToOfferingStatus < ActiveRecord::Migration
  def self.up
    add_column :offering_statuses, :allow_application_edits, :boolean
    add_column :offering_statuses, :allow_abstract_revisions, :boolean
    add_column :offering_statuses, :allow_abstract_confirmation, :boolean
    add_column :offering_statuses, :allow_confirmation, :boolean
  end

  def self.down
    remove_column :offering_statuses, :allow_confirmation
    remove_column :offering_statuses, :allow_abstract_confirmation
    remove_column :offering_statuses, :allow_abstract_revisions
    remove_column :offering_statuses, :allow_application_edits
  end
end
