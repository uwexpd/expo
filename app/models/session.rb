class Session < ActiveRecord::Base
  def self.sweep(time = 1.day.ago)
    if time.is_a?(String)
       time = Time.now - time.split.inject{ |count, unit| count.to_i.send(unit) }
    end    
    self.delete_all "updated_at < '#{time.to_s(:db)}' OR created_at < '#{2.days.ago.to_s(:db)}'"
  end
end
