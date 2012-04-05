class ChangeUploadedFileIdInApplicationFiles < ActiveRecord::Migration
  def self.up
    rename_column :application_files, :uploaded_file_id, :offering_question_id
  end

  def self.down
    rename_column :application_files, :offering_question_id, :uploaded_file_id
  end
end
