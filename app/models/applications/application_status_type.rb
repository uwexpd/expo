# Keeps track of the different status types through which an ApplicationForOffering can go.  The model stores a unique name and an optional description.  The +description_pretty+ method can be used to provide a pretty version of the name or description automatically.
# More details at ApplicationStatus.
class ApplicationStatusType < ActiveRecord::Base
  stampable
  has_many :application_statuses
  has_many :offering_statuses

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def description_pretty
    description || name.titleize
  end
  
  def name_pretty
    name.titleize
  end
  
  def emails_for(offering_id)
    os = offering_statuses.find_by_offering_id(offering_id)
    os.nil? ? Array.new : os.emails
  end
end