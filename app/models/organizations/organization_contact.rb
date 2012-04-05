# An Organization can have multiple OrganizationContacts, which links a Person record to an Organization. Note that this model overrides the #destroy methods so that, by default, an organization contact is simply marked as +current = false+ so that they still show up when looking at historical records.
class OrganizationContact < ActiveRecord::Base
  stampable
  include Comparable
  
  include ChangeLogged
  acts_as_soft_deletable
  
  belongs_to :person
  belongs_to :organization
  has_many :supervised_positions, :class_name => "ServiceLearningPosition", :foreign_key => "supervisor_person_id", :dependent => :nullify

  has_one :token, :as => :tokenable
  after_save :create_token_if_needed
  
  has_many :organization_contact_units, :dependent => :destroy
  has_many :units, :through => :organization_contact_units
  
  validates_presence_of :person_id
  validates_presence_of :organization_id
  
  validates_associated :person
  validates_associated :organization
  
  delegate :fullname, :contact_histories, :to => :person

  named_scope :americorps, :conditions => { :americorps => true }
  
  named_scope :all, :conditions => { :current => true }
  named_scope :all_with_not_current
  named_scope :not_current, :conditions => { :current => false }
  
  PLACEHOLDER_CODES = %w(login_url usernames)
  PLACEHOLDER_ASSOCIATIONS = %w(person organization)

  def <=>(o)
    return person.lastname <=> o.person.lastname unless person.lastname == o.person.lastname
    person.firstname <=> o.person.firstname
  rescue
    -1
  end
  
  def person=(person_attributes)
    if person.nil?
      create_person(person_attributes)
    else
      person.update_attributes(person_attributes)
    end
  end

  def login_url
    token.generate rescue create_token
    "http://#{CONSTANTS[:base_system_url]}/community_partner/?map=#{id}&t=#{token.token}"
  end

  attr_accessor :new_token
  def new_token=(t)
    unless t.blank?
      create_token if token.nil?
      token.update_attribute(:token, t)
    end
  end
  
  def contact_units=(contact_units)
    self.unit_ids = contact_units[:unit_ids].nil? ? [] : contact_units[:unit_ids]
    organization_contact_units.each do |ocu|
      ocu.primary_contact = contact_units[:primary_contact].nil? ? false : contact_units[:primary_contact].include?(ocu.unit_id.to_s)
      ocu.save
    end
  end

  def primary_for_unit?(unit)
    unit = Unit.find(unit) unless unit.is_a?(Unit)
    !organization_contact_units.find(:all, :conditions => { :unit_id => unit.id, :primary_contact => true }).empty?
  end

  def contact_for_unit?(unit)
    unit = Unit.find(unit) unless unit.is_a?(Unit)
    self.unit_ids.include?(unit.id)
  end

  # Returns a comma-separated list of this person's login usernames, or nil if none exist.
  def usernames
    person.users.collect(&:login).join(", ") rescue nil
  end

  # Returns true if this contact is a supervisor for any positions with placed students in the specified quarter
  def active_supervisor_for?(quarter = Quarter.current_quarter)
    supervised_positions.each do |p|
      return true if !p.placements.filled.empty? && p.quarter == quarter
    end
    false
  end

  # Used in change logs
  def identifier_string
    fullname
  end

  # Overrides destroy to only set +current+ to false. This removes this organization contact from most lists
  # and other places, but still keeps the object valid for associations like when he or she is a supervisor for
  # an old ServiceLearningPosition. If you truly want to destroy this object from the database, use #destroy!.  
  def destroy
    self.update_attribute(:current, false)
  end

  # Destroys this object like you would normally expect.
  def destroy!
    self.destroy
  end

  protected
  
  def create_token_if_needed
    create_token if token.nil?
  end

end
