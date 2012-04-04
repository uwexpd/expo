class Apply::LookupController < ApplyController
  before_filter :check_if_uses_lookup
  
  skip_before_filter :login_required, :student_login_required_if_possible
  skip_before_filter :fetch_user_applications, :choose_application, :redirect_to_group_member_area, :check_restrictions, :check_must_be_student_restriction, :display_submitted_note
  
  before_filter :fetch_applicants
  before_filter :fetch_majors, :fetch_departments, :fetch_awards
    
  def index
  end
  
  def result
    @query_strings = {}
    @result = []
    @result = find_by_student_name(params[:student_name]) if params[:student_name]
    @result = find_by_mentor_name(params[:mentor_name]) if params[:mentor_name]
    @result = find_by_department(params[:mentor_department]) if params[:mentor_department]
    @result = find_by_major(params[:student_major]) if params[:student_major]
    @result = find_by_award(params[:student_award]) if params[:student_award]
    @result = @result.uniq.sort unless @result.empty?
    render :action => "index"
  end
  
  protected
  
  def check_if_uses_lookup
    unless @offering.uses_lookup?
      render :text => "This offering process does not use the lookup tool." and return
    end
  end
  
  def find_by_student_name(query)
    @query_strings[:student_name] = query
    result = []
    @all.each do |a|
      count = a.fullname.downcase.scan(query.downcase).size
      result << a.app unless count.zero?
    end
    result
  end

  def find_by_mentor_name(query)
    @query_strings[:mentor_name] = query
    result = []
    @all.each do |a|
      a.app.mentors.each do |m|
        count = m.fullname.downcase.scan(query.downcase).size
        result << a.app unless count.zero?
      end
    end
    result
  end

  def find_by_department(query)
    result = @departments.values_at(query).flatten
    result = result.collect{|r| r.app}.flatten
  end

  def find_by_major(query)
    result = @majors.values_at(query).flatten.compact
    result = result.collect{|r| r.app}.flatten
  end
  
  def find_by_award(query)
    result = @awards.values_at(query).flatten
    result = result.collect{|r| r.app}.flatten
  end  
  
  # Fetches all primary presenters and group members in the confirmed status
  def fetch_applicants
    @apps = @offering.application_for_offerings.with_status(:confirmed)
    @all = (@apps + @apps.collect(&:group_members)).flatten.compact
    @applicants = @all.collect(&:person).flatten.compact.uniq
  end
  
  def fetch_majors
    @majors ||= {}
    @major_extras ||= MajorExtra.all
    @major_abbrs ||= {}
    for major_extra in @major_extras
      @major_abbrs[major_extra.major_abbr.strip] = [] unless @major_abbrs[major_extra.major_abbr.strip]
      @major_abbrs[major_extra.major_abbr.strip] << major_extra
    end
    for a in @all
      if a.person
        for major in a.person.majors
          major_name = major
          if major.is_a?(StudentMajor)
            # major_extra_field = @major_extras.select{|m| major.major_abbr.strip == m.major_abbr.strip }
            # major_extra = major_extra_field.select{|m| major.branch == m.major_branch && major.pathway == m.major_pathway }
            if @major_abbrs[major.major_abbr.strip]
              major_extra = @major_abbrs[major.major_abbr.strip].find{|m| major.branch == m.major_branch && major.pathway == m.major_pathway }
            end
            major_name = major_extra.nil? ? major.full_name : major_extra.fixed_name 
          end
          @majors[major_name] = (@majors[major_name].nil? ? [a] : @majors[major_name] << a) unless major_name.blank?
        end
      end
    end
    @majors
  end

  def fetch_departments
    @departments ||= {}
    for a in @all
      dept = a.app.mentor_department
      @departments[dept] = (@departments[dept].nil? ? [a] : @departments[dept] << a) unless dept.blank?
    end
    @departments
  end
  
  def fetch_awards
    @awards ||= {}
    for a in @all
      award = a.app.other_awards.collect(&:title).flatten      
      for index in (0...award.length)
        @awards[award[index]] = (@awards[award[index]].nil? ? [a] : @awards[award[index]] << a) unless award.blank?
      end
    end
    @awards
  end
  
end