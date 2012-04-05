class ApplicationOtherAward < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_other_award_type
  belongs_to :award_quarter, :class_name => "Quarter", :foreign_key => "award_quarter_id"
  
  delegate :restrict_number_of_awards_to, :title, :scholar_title, :to => :offering_other_award_type

  validates_presence_of :offering_other_award_type_id

  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def <=>(o)
    title <=> o.title rescue 0
  end
    
end
