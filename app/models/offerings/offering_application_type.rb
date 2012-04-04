class OfferingApplicationType < ActiveRecord::Base
  stampable
  belongs_to :offering
  belongs_to :application_type
  belongs_to :workshop_event, :class_name => "Event", :foreign_key => "workshop_event_id"
  has_many :offering_application_categories
  has_many :offering_sessions

  validates_presence_of :offering_id, :application_type_id
  
  delegate :title, :description, :to => :application_type
  
  PLACEHOLDER_CODES = %w(offering title description)
  
  def <=>(o)
    title <=> o.title rescue 0
  end
end
