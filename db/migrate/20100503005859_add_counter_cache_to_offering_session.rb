class AddCounterCacheToOfferingSession < ActiveRecord::Migration
  def self.up
    add_column :offering_sessions, :presenters_count, :integer
    
    for s in OfferingSession.all
      s.update_attribute(:presenters_count, s.presenters.size)
    end
    
  end

  def self.down
    remove_column :offering_sessions, :presenters_count
  end
end
