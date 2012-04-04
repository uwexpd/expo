class DisciplineCategory < ActiveRecord::Base
	has_many :major_extras, :class_name => "MajorExtra", :foreign_key => "discipline_category_id"
	
	default_scope :order => "name"
	
	def <=>(o)
		name <=> o.name rescue 0
	end
	
	def majors
		return self.major_extras
	end
	
  # Used to create a default "Unknown" discipline category when needed. This allows us to avoid creating one in the DB.
  def self.unknown
    @unknown ||= self.new(:name => "Unknown")
  end
	
end