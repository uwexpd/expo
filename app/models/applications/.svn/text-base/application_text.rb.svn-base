# An ApplicationForOffering can have many ApplicationTexts, which can really be any block of text. Originally it was designed for research abstracts, which are designed to be typed directly into the web form rather than be uploaded like an ApplicationFile is. Every ApplicationText is versioned so that you can always restore to a previous version or view change history. The +body+ and +body=+ methods automatically get and set the body text of new or current versions, so the versioning happens in the background.
class ApplicationText < ActiveRecord::Base
  stampable
  
  belongs_to :application_for_offering
  has_many :versions, :class_name => "ApplicationTextVersion"
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :application_for_offering_id
  
  # Returns the body of this ApplicationText for the most recent version.
  def body
    return nil unless current_version
    current_version.text
  end
  
  # The current version of this text is the last one to be inserted into the database. Returns the ApplicationTextVersion object or nil.
  def current_version
    versions.last || nil
  end
  
  # Creates a new version of the text and populates the version's +text+ attribute if this new text is different from the current version.
  # Returns the body text.
  def body=(new_body)
    versions.create(:text => new_body) unless body.eql?(ApplicationTextVersion.sanitize(new_body))
    body
  end
  
  # Returns true if the current version has a blank body text.
  def blank?
    body.blank?
  end
  
end
