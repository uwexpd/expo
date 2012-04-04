=begin rdoc
  Represents some quoteable text that can be used in a number of different contexts. The generic +key+ attribute can be used to group related quotes together.
=end
class Quote < ActiveRecord::Base
  validates_presence_of :key, :quote
  
  belongs_to :quotable, :polymorphic => true
  
  default_scope :order => "`key` ASC"
  
  named_scope :key, lambda { |key| {:conditions => { :key => key.to_s } } }
  named_scope :random, :order => 'RAND()', :limit => 1
  
  image_column :picture, 
              :versions => { :thumb => "50x50", :small => "150x150", :large => "300x300" }, 
              :store_dir => proc{|record, file| "shared/quote/#{record.id}/picture"} 
  
end
