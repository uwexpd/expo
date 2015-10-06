class ServiceLearningSelfPlacement < ActiveRecord::Base
  
  belongs_to :course, :class_name => "ServiceLearningCourse"
  belongs_to :position, :class_name => "ServiceLearningPosition"
  belongs_to :placement, :class_name => "ServiceLearningPlacement"
  belongs_to :person
  belongs_to :quarter  
  
  delegate :fullname, :to => :person
  
  attr_accessor :require_validations, :self_placement_validations, :general_study_validations, :confirm_registered
  
  acts_as_strip :organization_contact_person, :organization_contact_phone, :organization_contact_email, :organization_contact_title, :organization_id, :organization_mailing_line_1, :organization_mailing_line_2, :organization_mailing_city, :organization_mailing_state, :organization_mailing_zip, :organization_website_url
  
  validate :organization_id_cannot_be_blank
  validates_presence_of :organization_contact_person, :if => :require_validations?
  validates_presence_of :organization_contact_phone, :if => :require_validations?
  validates_presence_of :organization_contact_email, :if => :require_validations?
  validates_format_of   :organization_contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :require_validations?

  validates_presence_of :hope_to_learn, :if => :self_placement_validations?
    
  validates_presence_of :faculty_firstname, :if => :general_study_validations?
  validates_presence_of :faculty_lastname, :if => :general_study_validations?
  validates_presence_of :faculty_dept,  :if => :general_study_validations?
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
    unless organization_id.blank?
      organization_id.try(:is_numeric?)
    else
      !new_organization?
    end
  end
  
  def existing_organization
    Organization.find(organization_id) if existing_organization?
  end
  
  def organization_name
    existing_organization? ? existing_organization.title : organization_id rescue "#error"
  end
    
  # def create_contact?
  #   !organization_contact_person.blank? && position.supervisor.nil?
  # end
    
  def status(tag = false)
    if admin_approved==false
         tag ? "<span class='tag'>admin declined</span>" : "<span class='red'>admin declined</span>"
    elsif faculty_approved? && !admin_approved?
         tag ? "<span class='tag'>faculty approved</span>" : "<span class='highlight'>faculty approved</span>"
    elsif admin_approved?
         tag ? "<span class='tag green'>admin approved</span>" : "<span class='green-check'>admin approved</span>"
    elsif faculty_approved==false && !submitted? 
         tag ? "<span class='tag'>faculty declined</span>" : "<span class='red'>faculty declined</span>"
    elsif submitted?
         tag ? "<span class='tag'>submitted</span>" : "submitted"
    else
         tag ? "<span class='tag'>in progress</span>" : "in progress"
    end   
  end
    
  def general_study_status(tag = false)
    if faculty_approved? && !supervisor_approved? && admin_approved.nil?
      tag ? "<span class='tag'>only faculty approved</span>" : "<span class='highlight'>only faculty approved</span>"
    elsif supervisor_approved? && !faculty_approved? && admin_approved.nil?
      tag ? "<span class='tag'>only supervisor approved</span>" : "<span class='highlight'>only supervisor approved</span>"
    elsif supervisor_approved? && faculty_approved? && admin_approved.nil?
      tag ? "<span class='tag'>both faculty and supervisor approved</span>" : "<span class='highlight'>both faculty and supervisor approved</span>"
    elsif admin_approved
      tag ? "<span class='tag green'>admin approved</span>" : "<span class='green-check'>admin approved</span>"
    elsif admin_approved == false
      tag ? "<span class='tag red'>admin declined</span>" : "<span class='red'>admin declined</span>"
    elsif submitted?
      tag ? "<span class='tag'>submitted</span>" : "submitted"
    else
      tag ? "<span class='tag'>submitted</span>" : "in progress"
    end
  end
  
  protected
  
  def organization_id_cannot_be_blank    
    if new_organization?
        errors.add_to_base "New organization name cannot be blank." if organization_id.blank?
    else
        errors.add_to_base "Please select an organization" if organization_id.blank?
    end    
  end
end
