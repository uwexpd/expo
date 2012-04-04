# Models a timeslot that is valid for a ServiceLearningPosition. A ServiceLearningPosition might have multiple time slots per week, or only one. Times may also be flexible, in which case a student can arrive anytime within the selected times to get work done.
class ServiceLearningPositionTime < ActiveRecord::Base
  stampable
  belongs_to :service_learning_position
  
  acts_as_soft_deletable
  
  attr_accessor :should_destroy
  
  # Returns a textual representation of this time
  def pretty_print
    days = []
    %w(monday tuesday wednesday thursday friday saturday sunday).each do |day|
      days << day.titleize if self.read_attribute(day)
    end
    days_join = days.empty? ? "All days" : days.join(', ')
    days_join = "Weekdays" if days_join == "Monday, Tuesday, Wednesday, Thursday, Friday"
    t = "#{days_join} from #{start_time.to_formatted_s(:time12)} to #{end_time.to_formatted_s(:time12)}"
    t << " (choose your shift within these hours)" if flexible?
    t
  rescue
    nil
  end

  # Provides an array of timecodes that are valid for this time object, in the form of "time_13:30_tuesday".
  # If this time spans more than 30 minutes, a timecode is returned for each 30-minute block.
  def timecodes
    return [] if start_time.nil?
    start_hour = start_time.strftime("%H")
    start_min = start_time.strftime("%M").to_i < 30 ? "00" : "30"
    curr_time = Time.parse("#{start_hour}:#{start_min}")
    timecode_array = []
    while curr_time < Time.parse("#{end_time.strftime("%H")}:#{end_time.strftime("%M")}") - 1.second
      timecode_array << "#{curr_time.strftime("%H").to_i}:#{curr_time.strftime("%M")}"
      curr_time = curr_time + 30.minutes
    end
    timecode_array_with_days = []
    %w(monday tuesday wednesday thursday friday saturday sunday).each do |day|
      timecode_array_with_days << timecode_array.collect{|t| "#{t}_#{day}"}.flatten if read_attribute(day)
    end
    timecode_array_with_days.flatten
  end
  
end
