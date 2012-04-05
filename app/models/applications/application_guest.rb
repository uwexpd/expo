# Applicants and group members can invite guests to an associated event, such as the research symposium or a scholarship awards dinner. This models that association. Note that this model is NOT connected to any true Event objects.
class ApplicationGuest < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :group_member, :class_name => "ApplicationGroupMember", :foreign_key => "group_member_id"
  belongs_to :mentor, :class_name => "ApplicationMentor", :foreign_key => "application_mentor_id"
  
  validates_presence_of :firstname, :lastname, :address_block
  
  def invitation_mailed?
    !invitation_mailed_at.nil?
  end

  def fullname
    "#{firstname} #{lastname}"
  end
  
  # For UW Campus addresses, returns "Box " followed by the address block. For all others, just returns the address block.
  def formatted_address
    uw_campus? ? "Box #{address_block}" : address_block
  end
  
  # Returns the object that invited this guest; either an ApplicationForOffering or an ApplicationGroupMember. If both are set, 
  # we return the group member.
  def inviter
    group_member || application_for_offering || nil
  end
  
  # Returns true if this guest has a custom postcard text defined. When printing postcards, the custom one is used if it exists,
  # otherwise it is calculated on the fly.
  def custom_postcard_text?
    !read_attribute(:postcard_text).blank?
  end
  
  def default_postcard_text
    app = application_for_offering || group_member
    app.app.offering.parse_guest_postcard_layout(inviter)
  end
  
  # Returns the parsed postcard layout code for the inviter that's passed to it, using Offering#guest_postcard_layout.
  def postcard_text
    custom_postcard_text? ? read_attribute(:postcard_text) : default_postcard_text
  end
  
end
