class MajorRestriction < OfferingRestriction
  
  validates_presence_of :parameter, :message => "must include at least one major abbreviation."
  
  def allows?(application_for_offering)
    @person = application_for_offering.person
    !(allowed_majors & @person.majors.collect { |m| m.major_abbr.strip }).empty?
  end

  def title
    "You must be in a specific major."
  end

  def detail
    "In order to apply for the #{self.offering.name}, you must be declared in one of the following majors:
    <ul>#{allowed_majors.sort.collect{|m| "<li>#{m}</li>"}.join}</ul>"
  end
  
  def allowed_majors
    majors ||= []
    parameter.to_s.split(",").collect(&:strip).each{|m| majors << Major.find_by_abbrev(m).title}
    majors
  end
  
end
