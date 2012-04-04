# Users can have multiple email addresses that they use to send mass e-mails from. Users can create as many as they want, and set a default one as well.
class UserEmailAddress < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :email
  validates_uniqueness_of :email, :scope => :user_id
  
  attr_accessor :default
  after_save :update_default
  
  # Returns a string like "Matt Harris <mharris2@uw.edu>".
  def to_header
    "#{name} <#{email}>"
  end
  
  # If the +default+ attribute was set to true, then update the +default_email_address_id+ in +user+. This is an +after_save+ callback.
  def update_default
    user.update_attribute(:default_email_address_id, self.id) if default && self.id      
  end

  # Returns true if this is the user's default email address
  def default?
    user.default_email_address == self
  end
  
end
