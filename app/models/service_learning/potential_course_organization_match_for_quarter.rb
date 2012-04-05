# Used to match an Organization to a Course during the Service Learning development process. These relationships are only used during the planning process; the true relationships between Organization and Course are facilitated through the ServiceLearningPositions and subsequent ServiceLearningPlacements which allocate volunteer slots to each course or program that is involved in Service Learning for the given quarter.
class PotentialCourseOrganizationMatchForQuarter < ActiveRecord::Base
  stampable
  belongs_to :organization_quarter
  belongs_to :service_learning_course
  
  validates_presence_of :organization_quarter_id
  validates_presence_of :service_learning_course_id

  validates_uniqueness_of :service_learning_course_id, :scope => :organization_quarter_id

  delegate :organization, :to => :organization_quarter

end
