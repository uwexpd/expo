class Unit < ActiveRecord::Base
  has_many :user_unit_roles, :order => :login do
    def for_user(user); find(:all, :conditions => { :user_id => user.id }); end
  end
  has_many :users, :through => :user_unit_roles, :order => :login
  has_many :roles, :class_name => "UserUnitRole", :foreign_key => "unit_id"
  has_many :events, :class_name => "Event", :foreign_key => "unit_id", :dependent => :nullify
  has_many :event_times, :through => :events, :source => :times
  has_many :offerings
  
  has_many :organization_quarters, :class_name => "OrganizationQuarter", :foreign_key => "unit_id"
  
  has_many :service_learning_positions, :class_name => "ServiceLearningPosition", :foreign_key => "unit_id"
  has_many :service_learning_courses, :class_name => "ServiceLearningCourse", :foreign_key => "unit_id"
  
  has_many :organization_contact_units, :dependent => :destroy
  has_many :organization_contacts, :through => :organization_contact_units
  
  has_many :service_learning_position_shares
  
  validates_presence_of :name, :abbreviation
  validates_uniqueness_of :name, :abbreviation
  
  image_column :logo, 
              :versions => { :thumb => "100x50", :medium => "150x150", :large => "300x300" }, 
              :store_dir => proc{|record, file| "shared/unit/#{record.id}/logo"} 
  
  named_scope :for_welcome_screen, :conditions => { :show_on_expo_welcome => true }
  named_scope :for_equipment_reservation, :conditions => { :show_on_equipment_reservation => true }
  named_scope :with_description, :conditions => "description != ''"
  
  default_scope :order => 'name'
  
  def <=>(o)
    name <=> o.name rescue 0
  end
  
  def to_param
    "#{abbreviation.parameterize}"
  end
  
  # Alias for #name
  def title
    name
  end

  # Returns the +engage_url+ if it exists, otherwise returns the +home_url+ for this unit. The +engage_url+ is meant
  # to be an URL that is specifically aimed at engaging a visitor to participate in the program, not just information.
  def engage_url
    return read_attribute(:engage_url) unless read_attribute(:engage_url).blank?
    home_url
  end

  # Returns the users from this unit that have the specified role. +role+ can be a string, a symbol, or an actual Role object.
  # If the Role can't be found, return an empty Array. Otherwise, return an array of the users in the role.
  def users_in_role(role)
    role = Role.find_by_name(role.to_s) unless role.is_a?(Role)
    return [] if role.nil?
    roles.find(:all, :conditions => { :role_id => role.id })
  end

  # Overrides #method_missing so that you can quickly check the abbreviation of the unit, like "unit.carlson?"
  def method_missing(method, *args)
    if m = method.to_s.match(/(\w+)\?/)
      return abbreviation == m[1] ? true : false
    else
      super
    end
  end

end
