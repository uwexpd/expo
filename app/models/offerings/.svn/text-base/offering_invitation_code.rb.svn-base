# If we need to restrict access to apply for an Offering to only certain individuals, we can create InvitationCodes that people can use to bypass a certain restriction, like the MustBeStudentRestriction.
class OfferingInvitationCode < ActiveRecord::Base
  stampable
  belongs_to :offering
  belongs_to :application_for_offering
  belongs_to :institution
  
  validates_presence_of :offering_id
  validates_presence_of :code
  validates_uniqueness_of :code, :scope => :offering_id
  
  # If this code has not been assigned to an application yet, it is considered "available" for use.
  def available?
    application_for_offering.nil?
  end
  
  # Assigns this code to a specific application if it is still available for use.
  def assign_to(app)
    update_attribute(:application_for_offering_id, app.id) if available?
  end
  
  # Generates a random code that can be used with the specified Offering, or, if n > 1, generate a whole block.
  def self.generate(offering, n = 1, institution_id = nil, note = nil)
    if n > 1
      codes = []
      n.times { codes << self.generate(offering, 1, institution_id, note) }
      return codes
    end
    OfferingInvitationCode.create(:offering_id => offering.id, :code => self.random_string, :institution_id => institution_id, :note => note)
  end
    
  def self.random_string(length = 8)
    res = ""
    length.times { res << 'ABCDEFGHIJKLMNOPQRSTUVWXYZ23456789'[rand(34)] }
    res
  end
  
end
