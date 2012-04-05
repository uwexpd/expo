class ApplicationStatus < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :application_status_type
  belongs_to :status_type, :class_name => "ApplicationStatusType"
  has_many :contact_histories
  has_many :notes, :as => :notable

  acts_as_soft_deletable
  validates_presence_of :application_for_offering, :application_status_type
    
  def name
    application_status_type.name
  end
  
  def description
    application_status_type.description_pretty
  end

  def offering_status
    # TODO this should probably be a real assocation!
    OfferingStatus.find_by_offering_id_and_application_status_type_id(application_for_offering.offering_id, application_status_type_id)
  end
  
  def sequence
    offering_status.nil? ? 0 : offering_status.sequence
  end
  
  def message
    offering_status.nil? ? "" : offering_status.message
  end
  
  def public_title
    offering_status.nil? ? "(Processing)" : offering_status.public_title
  end
  
  def note=(note_text)
    notes.build :note => note_text unless note_text.blank?
  end
  
end
