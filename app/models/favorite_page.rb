class FavoritePage < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :url, :title, :user_id
  validates_uniqueness_of :url, :scope => :user_id
  
  acts_as_list :scope => :user
end
