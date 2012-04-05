# Each ServiceLearningPosition is supposed to have an Orientation for students. In some cases, the Orientation is flexible, meaning that the times are not rigid; this does _not_ mean that the orientation is optional.
class ServiceLearningOrientation < ActiveRecord::Base
  stampable
  belongs_to :orientation_location, :class_name => "Location", :foreign_key => "location_id"
  belongs_to :orientation_contact, :class_name => "OrganizationContact", :foreign_key => "organization_contact_id"
  has_one :service_learning_position
  acts_as_soft_deletable
  
  def location=(location_attributes)
    new_location_id = location_attributes.delete(:location_id)
    is_new_location = location_attributes.delete(:new_location)
    needs_update = location_attributes.delete(:needs_update)
    if orientation_location.nil? || is_new_location
      new_location = create_orientation_location(location_attributes)
      self.update_attribute(:location_id, new_location.id)
    elsif new_location_id.to_i == location_id.to_i && needs_update == "true"
      orientation_location.update_attributes(location_attributes)
    end
  end

  def location
    different_orientation_location? ? orientation_location : service_learning_position.location
  end
  
  def contact
    orientation_contact || service_learning_position.supervisor
  end
  
end
