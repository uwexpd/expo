class OfferingStatusEmail < ActiveRecord::Base
  stampable
  belongs_to :offering_status
  belongs_to :email_template
  
  validates_presence_of :offering_status_id
  validates_presence_of :email_template_id
  
  def auto_send?
    auto_send || false
  end
  
end
