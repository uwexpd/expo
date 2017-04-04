class StudentResource < WebServiceResult
  
  SWS_VERSION = "v5"

  self.element_path = "student/#{SWS_VERSION}/person"  
  self.cache_lifetime = 1.hour

  ATTRIBUTE_ALIASES = {
    :StudentName      => [:fullname],
    :StudentNumber    => [:student_no],
    :UWNetID          => [:uw_netid]
  }
  
  def self.method_missing(method, *args)
    if method.to_s =~ /find_by_system_key/
      attribute = :student_system_key
    elsif method.to_s =~ /find_by_reg_id/
      return StudentResource.find(args)
    elsif method.to_s =~ /find_by_(net_id|uw_netid)/
      attribute = :net_id
    elsif method.to_s =~ /find_by_(student_number|student_no)/
      attribute = :student_number
    else
      super
    end
    self.find_by_attribute(attribute, *args)
  end

  # Finds a Student by any attribute or nil if no record was found.
  # By default this will return a StudentResource object, but you can pass +false+ for the +fetch_record+
  # parameter and you'll just get the reg_id for the student.
  def self.find_by_attribute(attribute, search_term, fetch_record = true)
    result = self.encapsulate_data(connection.get("#{self.element_path}?#{attribute.to_s}=#{search_term.to_s}"))
    result_elements = result.css("Person RegID") # For SWS v4 -> result_elements = result.xpath("//a[@rel='search_result']/span[@class='reg_id']") 

    return nil if result_elements.empty?
    fetch_record ? self.find(result_elements.first.content) : result_elements.first.content
  end

  def photo
    @photo ||= StudentPhoto.new(@id)
  end
    
  def lastname
    #fullname.split(',')[0] rescue self.LastName
    self.LastName.try(:titleize)
  end
  
  def firstname
    #fullname.split(',')[1].split(' ')[0] rescue self.FirstName
    self.FirstName.try(:titleize)
  end
  
  def fullname
    #self.StudentName.strip.gsub(',', ', ')
    lastname + ", " + firstname
  end
  

end