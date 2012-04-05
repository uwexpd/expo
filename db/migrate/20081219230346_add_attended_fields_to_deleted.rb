class AddAttendedFieldsToDeleted < ActiveRecord::Migration
  def self.up
    ApplicationForOffering::Deleted.update_columns
    ApplicationFile::Deleted.update_columns    
  end

  def self.down
    ApplicationForOffering::Deleted.update_columns
    ApplicationFile::Deleted.update_columns
  end
end
