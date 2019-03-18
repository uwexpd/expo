require 'digest/sha1'
class User < ActiveRecord::Base
  belongs_to :person
  has_many :offerings_with_approval_access, :class_name => "Offering", :foreign_key => "dean_approver_id"
  has_many :offerings_with_financial_aid_approval_access, :class_name => "Offering", :foreign_key => "financial_aid_approver_id"
  has_many :offerings_with_disbersement_approval_access, :class_name => "Offering", :foreign_key => "disbersement_approver_id"
  has_many :roles, :class_name => "UserUnitRole", :foreign_key => "user_id" do
    def for(unit_id); find(:all, :conditions => { :unit_id => unit_id }); end
  end
  has_many :units, :through => :roles do
    def minus_exp; find(:all, :conditions => "abbreviation != 'expd'"); end
  end
  has_many :organization_quarters, :class_name => "organization_quarter", :foreign_key => "staff_contact_user_id"
  has_many :logins, :class_name => "LoginHistory" do
    def latest
      find(:first, :order => 'created_at DESC')
    end
    def last
      find(:first, :order => 'created_at DESC', :offset => 1)
    end
  end
  has_one :latest_login, :class_name => "LoginHistory", :order => 'created_at DESC'
  has_many :email_addresses, :class_name => "UserEmailAddress"
  belongs_to :default_email_address, :class_name => "UserEmailAddress", :foreign_key => "default_email_address_id"
  has_many :favorite_pages, :order => 'position'
  has_many :proceedings_favorites do
    def for(offering)
      find(:all, :joins => :application_for_offering, :conditions => { "application_for_offerings.offering_id" => offering.id } )
    end
  end

  image_column :picture, 
              :versions => { :mini => "35x35", :thumb => "50x50", :large => "200x200" }, 
              :store_dir => proc{|record, file| "shared/user/#{record.id}/picture"} 


  PLACEHOLDER_CODES = %w( fullname login last_login_date firstname_first )
  
  # If the user has a default email address assigned, return its +to_header+ method. Otherwise, return +original_email_address_header+.
  def default_email_address_header
    default_email_address.nil? ? original_email_address_header : default_email_address.to_header
  end
  
  # The basic email address header, consisting of this person's email and name. e.g., "Matt Harris <mharris2@uw.edu>"
  def original_email_address_header
    "#{fullname} <#{email}>"
  end
  
  model_stamper

  has_one :token_object, :class_name => "Token", :as => :tokenable
  
  MAX_TOKEN_AGE = 1.day
  
  # Returns the actual token from this User's +token_object+ or generates a new one if:
  # 
  #  * no token object exists yet
  #  * the existing token is older than the MAX_TOKEN_AGE.
  def token
    return create_token_object.token if token_object.nil? || Time.now - token_object.updated_at > MAX_TOKEN_AGE
    token_object.token
  end
  
  def create_token
    create_token_object
  end
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :allow_invalid_person
  
  acts_as_strip :login, :email
  
  validates_presence_of     :login #, :person_id
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :person, :unless => :allow_invalid_person?
  validates_length_of       :login,    :within => 3..40
#  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :scope => [:type, :identity_type], :case_sensitive => false
  before_save :encrypt_password
  #validate :person_is_valid, :unless => :allow_invalid_person?
  validates_associated :person, :if => :check_person, :unless => :allow_invalid_person?
  
  def check_person
    return false if person.nil?
    unless person.is_a?(Student)
      return false if allow_invalid_person? # needed to let the pubcookie user not be validated
      person.require_validations = true
      return true
    else
      return false
    end
  end
  
=begin 
  def person_is_valid
    if person
      unless person.is_a?(Student)
        person.require_validations = true
        person.errors.each_full{ |e| errors.add_to_base(e) } unless person.valid?
      end
    else
      errors.add_to_base "Person can't be blank"
    end
  end
=end

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :person_attributes, :picture, :picture_temp  #, :person_id
  
  named_scope :admin, :conditions => { :admin => true }

  # Pulls the current user out of Thread.current. We try to avoid this when possible, but sometimes we need 
  # to access the current user in a model (e.g., to check EmailQueue#messages_waiting?).
  def self.current_user
    Thread.current['user']
  end

  def person_attributes=(person_attributes)
    if person.nil?
      self.person = Person.new(person_attributes)
    else
      self.person.update_attributes(person_attributes)
    end
  end
  
  # Returns a user's full name based on person's info
  def fullname
    person.fullname_unknown? ? login : person.fullname rescue login
  end
  
  # Returns the user's firstname_first from the person record
  def firstname_first
    person.fullname_unknown? ? login : person.firstname_first rescue login
  end
  
  def firstname
    person.fullname_unknown? ? login : person.firstname rescue login
  end
  
  # Returns the datetime of the last user login, or of the current login if this is the first logon for the user. Note that "last" 
  # login means the login previous to the current user session.
  def last_login_date
    logins.last.created_at rescue logins.latest.created_at rescue Time.now
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil. Note that this method is
  # case-insensitive, so "Mike" and "mike" will both return the same user object.
  def self.authenticate(login, password)
    logger.info "User.authenticate: #{login}, ******"
    u = find_by_login_and_type(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if this user's roles include the requested role. This can be passed as a symbol or string.
  # If the user must have the role assigned for a specific unit, specify the unit object or ID as the second parameter.
  # Note that "global" roles (i.e., roles with no unit assigned) will always return true regardless of the
  # unit that is passed.
  def has_role?(role, unit = nil)
    if unit
      unit = Unit.find(unit) unless unit.is_a?(Unit)
      roles.for(unit.id).collect(&:to_sym).include?(role.to_sym) || roles.for(nil).collect(&:to_sym).include?(role.to_sym)
    else
      roles.collect(&:to_sym).include?(role.to_sym)
    end
  end

  # Returns the authorizations that this user has for the specified role in an array of UserUnitRoleAuthorization objects,
  # or nil if the user does not have the role assigned.
  def authorizations_for(role)
    auth_roles = roles.find(:all, :joins => :role, :include => :authorizations, :conditions => { "roles.name" => role.to_s })
    return nil if auth_roles.empty?
    auth_roles.collect(&:authorizations).flatten.compact
  end
  
  # Returns true if this user is assigned a role for the specified unit.
  def in_unit?(unit)
    unit = Unit.find(unit) if unit.is_a?(Numeric)
    units.include?(unit)
  end
  
  def assign_role(role)
    return false if role.blank?
    role_type = Role.find_by_name(role.to_s)
    return false if role_type.nil?
    return roles.find_by_role_id(role_type.id) if has_role?(role)
    roles.create(:role_id => role_type.id)
  end

  # Returns a user type such as Student, Standard Users(uw staff and faulty), Exteranl Users(non-uw users)
  def user_type
    if self.class.name == "PubcookieUser"
      type = self.identity_type == "Student" ? self.identity_type : "UW Standard user"
    else
      type = "External user"
    end
    type
  end
  
  protected
  
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    # In some cases, we want to be able to update user attributes without worrying about a valid person record.
    # An example is when we are reseting the password and the form only allows them to edit passwords.
    def allow_invalid_person?
      allow_invalid_person
    end
    
end
