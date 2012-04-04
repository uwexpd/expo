# Each ApplicationForOffering object can have multiple ApplicationFiles attached to it.  In many cases this will be in the form of an actual attached file, such as a Word document, a PDF, or an image.  In some cases, the "file" will be stored as plain text, such as a simple letter or a student's essay that needs to be easily transferred or indexed; this is the purpose of the +text_version+ attribute.
class ApplicationFile < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_question
  
  acts_as_soft_deletable

  upload_column :file, 
                :root_dir => File.join(RAILS_ROOT, 'files'), 
                :versions => { :original => nil, :pdf => :convert_to_pdf },
                :old_files => :keep,
                :manipulator => UploadColumn::Manipulators::DocumentConverter,
                :filename => proc { |record, file| record.filename(record, file) },
                :store_dir => proc{ |record, file| File.join("application_file", "file", record.application_for_offering.id.to_s) },
                :public_filename => proc { |record, file| record.public_filename(record, file) },
                :fix_file_extensions => true,
                :get_content_type_from_file_exec => true
#                :extensions => %w(pdf rtf txt doc)

#  validates_integrity_of :file
                
  # Supplies the filename to use when saving and retrieving this file to the filesystem
  def filename(record, file)
    original = "#{file.basename}.#{file.extension}"
    write_attribute(:original_filename, original)
    ext = file.suffix.nil? || file.suffix == :original ? file.extension : file.suffix
    "#{application_for_offering.id.to_s}-#{title.gsub(/[\s,\.\\\/\*\?\%\:\|\"\'\<\>]?/,'')}.#{ext}"
  end

  # Supplies the filename to use when sending the file to the user's browser
  def public_filename(record, file)
    filename = [application_for_offering.id.to_s] 
    filename << application_for_offering.person.fullname
    filename << title
    ext = file.suffix.nil? || file.suffix == :original ? file.extension : file.suffix
    filename.join(' ').gsub(/[^a-z0-9 \(\)]+/i,'') + ".#{ext}"
  end
  
end
