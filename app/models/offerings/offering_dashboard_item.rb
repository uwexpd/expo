class OfferingDashboardItem < ActiveRecord::Base
  stampable
  belongs_to :offering
  belongs_to :dashboard_item
  belongs_to :offering_status, :class_name => "OfferingStatus"
  belongs_to :offering_application_type
  
  acts_as_list :column => 'sequence'
  
  delegate :title, :content, :icon, :css_class, :to => :dashboard_item
  
  validates_presence_of :offering_id, :dashboard_item_id
  validates_associated :dashboard_item
  
  named_scope :enabled, :conditions => "disabled IS NULL or disabled = 0"
  named_scope :disabled, :conditions => { :disabled => true }
  
  def <=>(o)
    sequence <=> o.sequence rescue 0
  end
  
  # Allow saving of dashboard item through mass assignment
  def dashboard_item_attributes=(attrs)
    if dashboard_item
      dashboard_item.update_attributes(attrs)
    else
      create_dashboard_item(attrs)
    end
  end
  
  # Evaluates the criteria for this item using the passed object. Object can be any type of object, potentially. If the object
  # is an ApplicationForOffering or responds to an :app method, then we also evaluate the other criteria for this dashboard item.
  # Returns true if this dashboard item should be shown for this object.
  def show_for?(object)
    return false if disabled?
    if object.respond_to?(:app)
      if offering_status
        application_status_type_name = offering_status.application_status_type.name
        return false unless object.app.send(status_lookup_method, application_status_type_name)
      end
      if offering_application_type
        return false unless object.app.application_type == offering_application_type
      end
    end
    return true if criteria.blank?
    (eval(criteria.to_s) rescue false) ? true : false
  end
  
end
