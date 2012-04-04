# Groups different pieces of Equipment together. For example, all of the Mac laptops might be in one group, and all of the Flip cameras might be in another group.
class EquipmentCategory < ActiveRecord::Base
  has_many :equipments
  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  image_column :picture, 
              :versions => { :thumb => "50x50", :large => "300x300" }, 
              :store_dir => proc{|record, file| "shared/equipment/categories/#{record.id}/picture"}              
  
  DEFAULT_MAX_CHECKOUT_DAYS = 90
  
  # Default sort is by title
  def <=>(o)
    title <=> o.title rescue nil
  end
  
  # If +max_checkout_days+ is not set, then default to the number of days in a quarter.
  def max_checkout_days
    read_attribute(:max_checkout_days).blank? ? DEFAULT_MAX_CHECKOUT_DAYS : read_attribute(:max_checkout_days)
  end
  
end
