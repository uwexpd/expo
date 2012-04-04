# An Organization is an operating entity outside of the university. This could be a business, a non-profit, another educational institution, or a community group. In the context of EXPo, an Organization is any entity that can sponsor a project or program, such as a service learning course. An Organization can belong to one parent organization which has some administrative control over the Organization, and can also belong to one or more Coalitions (see note at Coalition about this difference).
class Organization < ActiveRecord::Base
  stampable
  
  include ChangeLogged
  acts_as_soft_deletable
  
  belongs_to :parent_organization, :class_name => "Organization"
  has_many :contacts, :class_name => "OrganizationContact", :dependent => :destroy, :include => [:person, :organization_contact_units], :conditions => { :current => true }
  has_many :former_contacts, :class_name => "OrganizationContact", :dependent => :destroy, 
                              :include => :person, 
                              :conditions => { :current => false }
  has_many :organization_quarters, :dependent => :destroy do
    def allowing_position_edits; find(:all, :conditions => ['allow_position_edits = ?', true]); end
    def allowing_unit_position_edits(unit); find(:all, :conditions => {:allow_position_edits => true, :unit_id => (unit.nil? ? nil : unit.class == Fixnum ? unit : unit.id)}); end
    def with_students_placed; find(:all).select{|oq| !oq.placements.filled.empty? }; end
    # search for org quarters by passing the unit id of the unit object
    def for_unit(unit); find(:all, :conditions => {:unit_id => (unit.nil? ? nil : unit.class == Fixnum ? unit : unit.id)}); end
    def for_quarter(quarter); find(:all, :conditions => { :quarter_id => (quarter.nil? ? nil : quarter.class == Fixnum ? quarter : quarter.id)}); end
  end
  #has_many :active_quarters, :through => :organization_quarters, :source => :quarter ## turned into a function
  has_many :service_learning_positions, :through => :organization_quarters, :source => :positions
  has_many :pipeline_positions, :through => :organization_quarters, :source => :pipeline_positions
  has_and_belongs_to_many :coalitions
  has_many :notes, :as => :notable, :dependent => :nullify
  belongs_to :default_location, :class_name => "Location"
  belongs_to :next_active_quarter, :class_name => "Quarter", :foreign_key => "next_active_quarter_id"
  has_many :locations
  
  validates_presence_of :name
  validates_uniqueness_of :name

  PLACEHOLDER_CODES = %w(name parent_organization.name inactive next_active_quarter.title)

  # Returns all organizations with +does_service_learning?+ set to true
  named_scope :service_learning, :conditions => { :does_service_learning => true }

  # Overrides #all so that by default we only return non-archived organizations.
  named_scope :all, :conditions => "archive IS NULL OR archive = false"
  
  # Finds all organizations, along with those that are archived.
  named_scope :all_with_archived
  
  default_scope :order => "name"
  
  def main_phone=(number)
    write_attribute :main_phone, number.to_s.gsub(/\D/,"")
  end
  
  def <=>(o)
    name <=> o.name
  end

  def title
    name
  end

  # Returns all Organizations that are not active for the current quarter (i.e., they do not have an associated OrganziationQuarter record
  # for the specified Quarter).
  def self.find_inactive(quarter, options = {})
    orgs = []
    if options[:unit_id]
      unit = Unit.find options[:unit_id]
      orgs = Organization.find(:all).reject{|o| o.active_for_quarter?(quarter, unit)}
      
    else
      orgs = Organization.find(:all).reject{|o| o.active_for_quarter?(quarter)}
    end
    orgs = orgs.select{|o| o.does_service_learning? } if options[:only_service_learning]
    orgs
  end
  
  # Returns true if this Organziation has an associated OrganizationQuarter record for the specified Quarter.
  def active_for_quarter?(quarter, unit=nil)
    active_quarters(unit).include? quarter
  end
  
  # Returns an array of quarters that the organiation has been activated for
  # Passing a unit will find the quarters that the organization was active for that specfic unit
  def active_quarters(unit=nil)
    unless unit.nil?
      organization_quarters.for_unit(unit).collect{|oq| oq.quarter}
    else
      organization_quarters.collect{|oq| oq.quarter}
    end
  end
  
  # Overrides the +url=+ setter to clean the URL when setting it
  def website_url=(new_url)
    write_attribute(:website_url, Organization.clean_url(new_url))
  end
  
  # Overrides the +url+ getter to clean the URL when reading it.
  def website_url
    Organization.clean_url(read_attribute(:website_url))
  end

  # Cleans a raw URL string, adding "http://" if no other protocol scheme is present. This makes sure that auto_link works properly.
  def self.clean_url(url)
    return nil if url.blank?
    url = url.strip.match(/^\w{1,5}:\/\/.*/) ? url.strip : "http://" + url.strip  # add the protocol if missing
    url = url.strip.match(/^(\w{1,5}:\/\/)(\S+)/) ? url.strip.match(/^(\w{1,5}:\/\/)(\S+)/)[0] : url.strip # take out any other crap
  end

  # Collects all of the ContactHistory items from each of the organization contacts. This is useful for adding contact
  # history logs to site notes.
  def contact_histories
    @contact_histories ||= contacts.collect(&:contact_histories) + former_contacts.collect(&:contact_histories).flatten
  end

  # Returns an array of OrganizationContacts that are primary service learning contacts for the organization. If there are no
  # primary service learning contacts defined, then we just return all contacts with supervised positions for this organization.
  def primary_service_learning_contacts
    u = Unit.find_by_abbreviation("carlson")
    c = contacts.find(:all, :conditions => {:organization_contact_units => {:unit_id => u.id, :primary_contact => true}})
    c.empty? ? position_supervisor_contacts : c
  end
  
  def position_supervisor_contacts
    contacts.select{|contact| contact.supervised_positions.count > 0 }
  end
  
  def pipeline_contacts
    u = Unit.find_by_abbreviation("pipeline")
    c = contacts.find(:all, :conditions => {:organization_contact_units => {:unit_id => u.id}})
    c.empty? ? contacts : c
  end
  
  # returns the contacts for the organization that are associated with the passed unit
  # if it cant find any it will fall back to all the contacts
  def contacts_for_unit(unit)
    c = contacts.find(:all, :conditions => {:organization_contact_units => {:unit_id => unit.id}})
    return c.empty? ? contacts : c
  end
  
  # returns the contacts for the organization that are associated with the passed unit and
  # are marked as the primary contact
  # if it cant find any it will fall back to unit contacts then to all the contacts
  def primary_contacts_for_unit(unit)
    c = contacts.find(:all, :conditions => {:organization_contact_units => {:unit_id => unit.id, :primary_contact => true}})
    return c.empty? ? contacts_for_unit(unit) : c
  end
  
  # Returns the quarter that this organization was last active, meaning that it had students placed in a service learning position.
  # This could be the current quarter.
  def last_active_quarter
    organization_quarters.with_students_placed.sort.first
  end

  # Returns the quarter that this organization last had an OrganizationQuarter record. The organization may or may not have had
  # students placed in the quarter. Compare with #last_active_quarter. Specify a unit or unit ID to limit the search to OrganizationQuarters
  # with the specified unit.
  def last_organization_quarter(unit = nil)
    conditions = { :unit_id => (unit.is_a?(Unit) ? unit : Unit.find(unit)).id } if unit
    organization_quarters.find(:first, :joins => :quarter, :conditions => conditions, :order => "year DESC, quarter_code_id DESC")
  end

  # Used for change logs and other objects that request a unified "name" from this object.
  def identifier_string
    name
  end

  # Activates this Organization for the specified Quarter or does nothing if already active. Returns the OrganizationQuarter record. 
  # If +enable_position_edits+ is set to +true+, then this method allows enables community partner position editing access for the
  # new OrganizationQuarter. Also, if this Organization is marked Inactive, this unsets that boolean.
  def activate_for(quarter, enable_position_edits = false, unit = nil)
    unit = Unit.find_by_abbreviation("carlson") if unit.nil?
    unit = Unit.find(unit) unless unit.is_a?(Unit)
    oq = organization_quarters.find_or_create_by_quarter_id_and_unit_id(quarter.id, unit.id)
    oq.update_attribute(:allow_position_edits, true) if enable_position_edits
    update_attribute(:inactive, false)
    oq
  end

  # Sends an invite email to all primary service learning contacts for the organization and sets the command_after_delivery
  # on the email to activate the organization for the specified quarter.
  def invite_for(quarter)
    command_after_delivery = "Organization.find(#{id}).activate_for(Quarter.find(#{quarter.id}), true)"
    #  Send the email
    primary_service_learning_contacts.each do |r|
      tmail_object = OrganizationQuarter::MID_QUARTER_EMAIL_TEMPLATES['Invite only'].create_email_to(r)
      EmailQueue.queue(r.person_id, tmail_object, nil, command_after_delivery)
      @emails_sent = true
    end
  end
  
  # Marks this organization as inactive and sets the next active quarter to <tt>Quarter.current_quarter.next</tt> by default.
  # Pass a different quarter to set the next active quarter to that one instead.
  # 
  # NOTE I changed this method to always set the next_active_quarter if requested. There was code (commented out below)
  # that would only set the next_active_quarter if next_active_quarter was nil. I'm not sure why this is the case, but I'm 
  # commenting it out and we'll see what happens. [mharris2 8/25/10]
  def mark_inactive(quarter = Quarter.current_quarter.next)
    update_attribute(:inactive, true)
    update_attribute(:next_active_quarter_id, quarter.id) # if next_active_quarter.nil?
  end

end
