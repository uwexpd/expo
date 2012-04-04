# Models the different decisions a moderator can make about an application that has been assigned to his or her session. For example, "Accept" and "Reject" are common options. Multiple "success values" can be created with the +yes_option+ flag. This can be useful if two decision types could both be considered a successful decision, such as "Accept" and "Accept with Revisions."
class ApplicationModeratorDecisionType < ActiveRecord::Base
  stampable
  belongs_to :offering
  has_many :applications, :class_name => "ApplicationForOffering"
  
  validates_presence_of :offering_id
  
end
