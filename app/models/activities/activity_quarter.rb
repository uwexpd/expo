class ActivityQuarter < ActiveRecord::Base
  validates_presence_of :quarter_id
  
  belongs_to :quarter
  belongs_to :activity
  
  # If +number_of_hours+ is not zero, then return that. If not, calculate the total based on hours per week.
  def number_of_hours
    return read_attribute(:number_of_hours) unless read_attribute(:number_of_hours).nil? || read_attribute(:number_of_hours).zero?
    hours_per_week.to_i * Activity::WEEKS_PER_QUARTER
  end
  
end