class Admin::ServiceLearning::SearchController < Admin::ServiceLearningController

  def index
    session[:breadcrumbs].add "Search"
    unless params[:result].blank?
      klass = params[:result][/^(\D\S+)_/][0..-2].camelize rescue nil
      redirect_to_result(klass, params[:result]) and return unless klass == "AdvancedSearch" || klass.nil?
    end
    @results = fetch_search_results(params[:search][:query]) if params[:search] && params[:search][:query]
  end

  def auto_complete_model_for_search_query
    render :partial => "admin/service_learning/search/auto_complete", 
            :object => fetch_search_results(params[:search][:auto_complete], 5), 
            :locals => { :highlight_phrase => params[:search][:auto_complete] }
  end

  protected 

  def fetch_search_results(query, limit = 1000)
    return [] if query.blank?
    default_includes = %w(organization organization_contact service_learning_position service_learning_course)
    includes = params[:search][:include].keys rescue default_includes
    query = query.downcase
    @results = []
    if includes.include?('organization')
      @results << Organization.all_with_archived.find(:all, :conditions => [ 'LOWER(name) LIKE ?', "%#{query}%" ], :limit => limit)
    end
    if includes.include?('organization_contact')
      @results << @quarter.organization_contacts.find_all{|c| c.firstname.to_s.downcase.include?(query)}[0..limit]
      @results << @quarter.organization_contacts.find_all{|c| c.lastname.to_s.downcase.include?(query)}[0..limit]
    end
    if includes.include?('service_learning_position')
      @results << @quarter.service_learning_positions.find(:all, 
                    :conditions => [ 'LOWER(title) LIKE ? AND organization_quarters.unit_id = ?', "%#{query}%", @unit.id ], 
                    :limit => limit)
    end
    if includes.include?('service_learning_course')
      @results << @quarter.service_learning_courses.for_unit(@unit).find_all{|c| c.title.downcase.include?(query)}[0..limit]
    end
    if includes.include?('student')
      # @results << @quarter.potential_service_learners.find_all{|s| s.fullname.downcase.include?(query)}
      @results << Student.find_by_anything(query, limit)
    end
    @results = @results.flatten.compact.sort_by{|i| i.identifier_string.to_s}
  end

  def redirect_to_result(klass, result)
    klass = klass.constantize
    id = result[/(\d+)$/]
    object = klass.find(id)
    object_url =  case klass.to_s
                  when "Organization":              service_learning_organization_path(@unit, @quarter, object)
                  when "School":                    service_learning_organization_path(@unit, @quarter, object)
                  when "OrganizationContact":       service_learning_organization_path(@unit, @quarter, object.organization, :anchor => 'contacts')
                  when "ServiceLearningCourse":     service_learning_course_path(@unit, object.quarter, object)
                  when "ServiceLearningPosition":   service_learning_organization_position_path(@unit, object.quarter, object.organization, object)
                  when "Student":                   admin_student_path(object, :anchor => (@unit.abbreviation == 'pipeline' ? 'pipeline' : 'service_learning'))
    end
    redirect_to object_url and return unless object_url.nil?
  end
    
end