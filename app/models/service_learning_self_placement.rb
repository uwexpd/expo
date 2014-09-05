class ServiceLearningSelfPlacement < ActiveRecord::Base
  
  belongs_to :course, :class_name => "ServiceLearningCourse"
  belongs_to :position, :class_name => "ServiceLearningPosition"
  belongs_to :placement, :class_name => "ServiceLearningPlacement"
  belongs_to :person
  belongs_to :quarter  
  
  delegate :fullname, :to => :person
  
  attr_accessor :require_validations, :self_placement_validations, :general_study_validations, :confirm_registered
  
  acts_as_strip :organization_contact_person, :organization_contact_phone, :organization_contact_email, :organization_contact_title, :organization_id, :organization_mailing_line_1, :organization_mailing_line_2, :organization_mailing_city, :organization_mailing_state, :organization_mailing_zip, :organization_website_url
  
  validates_presence_of :organization_contact_person, :if => :require_validations?
  validates_presence_of :organization_contact_phone, :if => :require_validations?
  validates_presence_of :organization_contact_email, :if => :require_validations?
  validates_format_of   :organization_contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :require_validations?
  validates_presence_of :hope_to_learn, :if => :self_placement_validations?
  
  validates_presence_of :faculty_firstname, :if => :general_study_validations?
  validates_presence_of :faculty_lastname, :if => :general_study_validations?
  validates_presence_of :faculty_phone, :if => :general_study_validations?
  validates_presence_of :faculty_email, :if => :general_study_validations?
  validates_format_of   :faculty_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :general_study_validations?
    
  def require_validations?
    require_validations.nil? ? false : require_validations
  end

  def self_placement_validations?
    self_placement_validations.nil? ? false : self_placement_validations
  end

  def general_study_validations?
    general_study_validations.nil? ? false : general_study_validations
  end
  
  def existing_organization?
    organization_id.try(:is_numeric?)
  end
  
  def existing_organization
    Organization.find(organization_id) if existing_organization?
  end
  
  def organization_name
    existing_organization? ? existing_organization.title : organization_id
  end
    
  # def create_contact?
  #   !organization_contact_person.blank? && position.supervisor.nil?
  # end
    
  def status
    if faculty_approved? && !admin_approved
         "<span class='highlight'>faculty approved</span>"
    elsif admin_approved
         "<span class='green-check'>admin approved</span>"
    elsif submitted?
         "submitted"
    else
         "in progress"
    end   
  end
    
  def general_study_status
    if faculty_approved? && !supervisor_approved? && !admin_approved
      "<span class='highlight'>only faculty approved</span>"
    elsif supervisor_approved? && !faculty_approved? && !admin_approved
      "<span class='highlight'>only supervisor approved </span>"
    elsif supervisor_approved? && faculty_approved? && !admin_approved
      "<span class='highlight'>both faculty and supervisor approved</span>"  
    elsif admin_approved
      "<span class='green-check'>admin approved</span>"
    elsif submitted?
      "submitted"
    else
      "in progress"
    end
  end  
end
