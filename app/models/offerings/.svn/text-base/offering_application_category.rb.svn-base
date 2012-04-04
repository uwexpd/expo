class OfferingApplicationCategory < ActiveRecord::Base
  stampable
  belongs_to :offering
  belongs_to :application_category
  belongs_to :offering_application_type
  
  delegate :title, :description, :to => :application_category
  
  def <=>(o)
    sequence <=> o.sequence rescue 0
  end
end
