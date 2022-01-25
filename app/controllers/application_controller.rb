# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotification::Notifiable
  include AuthenticatedSystem, AuthorizedSystem
  include Userstamp

  rescue_from ExpoException, :with => :expo_exception
  rescue_from ActionController::RedirectBackError, :with => :redirect_exception
  
  before_filter :login_required, :except => [ 'remove_vicarious_login' ]
  before_filter :save_user_in_current_thread
  before_filter :check_for_limited_login
  before_filter :set_stamper # part of Userstamp -- moved here so that it is called *after* the login process
  before_filter :save_return_to
  before_filter :add_to_session_history
  before_filter :warn_if_maintenance_mode
  before_filter :verify_uwsdb_connection
  before_filter :save_dom_id_to_update
  before_filter :apply_popup_layout_if_requested
  before_filter :check_if_contact_info_blank
  
  # routing_navigator :on

  filter_parameter_logging :password
  # protect_from_forgery :secret => "mGg44KjlwppO2HXXmatTh9d3413501ba3117948a2441574e4e5de"
  #  had to disable this because model_auto_completer doesn't seem to work with it on.
  
  # Pick a unique cookie name to distinguish our session data from others'
  # session :session_key => '_expo_session_id'
  
  # Define site layout
  layout 'public'

  # Add return_to to session if it's been requested
  def save_return_to
    session[:return_to] = params[:return_to] unless params[:return_to].blank?    
  end
  
  def redirect_to_path
    new_path = session[:return_to]
    session[:return_to] = nil
    new_path || root_url
  end
  
  def local_request?
    false
  end
  # consider_local "172.28.99.10"

  # Forces a reconnect to the UWSDB by calling #reconnect! on the StudentInfo.connection object. If we aren't able
  # to connect, for any reason, then we render the uwsdb_error exception page along with a 503 status.
  def verify_uwsdb_connection
    ret = ""
    cmd = "StudentInfo.connection.reconnect!"
    time = Benchmark::realtime { ret = eval(cmd) }
    logger.info { "  \e[4;33;1mVerify UWSDB Connection (#{time.to_s[0..8]})\e[0m   #{cmd}" }
  rescue => e
    render :template => "exceptions/uwsdb_error", :layout => false, :status => 503
    logger.info { "  \e[4;33;1mVerify UWSDB Connection (#{time.to_s[0..8]})\e[0m   #{e}" }
  end

  def location_summary
    @location = Location.find(params[:id])
    respond_to do |format|
      format.js { render :partial => "admin/locations/summary", :object => @location }
    end
  end
  
  def location_fields
    @location = params[:id] == "new" ? Location.new : Location.find(params[:id])
    respond_to do |format|
      format.js { render :partial => "admin/locations/fields", :locals => {:prefix => params[:prefix], :object => @location } }
    end
  end

  def call_rake(task, log_file, options = {})
      options[:rails_env] ||= RAILS_ENV
      log_file ||= "rake"
      args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
      system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{RAILS_ROOT}/log/#{log_file}.log"
      exit! 127
  end

  def test_exception_notifier
    raise 'Test Exception. This is a test exception to make sure the exception notifier is working.'
  end

  private

  def save_user_in_current_thread
    Thread.current['user'] = @current_user
  end

  def check_for_limited_login
    if session[:limit_login_to]
      return redirect_to login_url unless request.request_uri.starts_with?(session[:limit_login_to])
    end
  end

  def adjust_format_for_iphone
    session[:skip_mobile] = true if params[:skip_mobile] == "true"
    session[:skip_mobile] = nil if params[:skip_mobile] == "false"
    if iphone_request? && !session[:skip_mobile]
      request.format = :iphone
    end
  end

  def iphone_request?
    # request.user_agent =~ /(Mobile\/.+Safari)/
    # Update to apply to mobile device instead of just iphone
    request.user_agent =~ /Mobile|webOS/
  end
  helper_method :iphone_request?
  
  def expo_exception(exception)
    @exception = exception
    render :template => "exceptions/expo_exception", :status => 200
  end
  
  def redirect_exception(exception)
    flash[:error] = "EXPO tried to redirect you back to the previous page, but there's no previous 
                     page to redirect you back to. You're going to have to find your own way from here."
    redirect_to root_url and return
  end
  
  def add_to_session_history
    SessionHistory.create(:session_id => request.session_options[:id], 
                          :request_uri => request.request_uri, 
                          :request_method => request.method.to_s)
  end
  
  def warn_if_maintenance_mode
    flash[:maintenance] = "Maintenance Mode is on for the public!" if FileTest.exists?(File.join(RAILS_ROOT, "public", "system", "maintenance.html"))
  end

  def save_dom_id_to_update
    session[:dom_id_to_update] = params[:dom_id_to_update] if params[:dom_id_to_update]
  end

  def apply_popup_layout_if_requested
    # layout 'popup' if params[:popup]
  end
  
  # assumes that the varables @filters and @quarter have been defined on the admin side
  # on the student side params["search"] and @quarter have been set
  # returns the search results
  # TODO Why is this in application_controller?!?!?
  def generate_pipeline_search(admin = false)
    unit = Unit.find_by_abbreviation "pipeline"
    
    if admin
      params["search"] = @filters
    end
    
    # this is the time that you split the during school and after school times on
    time_split = 13 # 1:00pm
    
    search_params = {}
    search_query = ""
    
    search_query = " organization_quarters.quarter_id = :quarter_id "
    search_params = search_params.merge({ :quarter_id => @quarter.id })
    
    unless params["search"]["target_school"].nil? && @filters["target_school"].nil?
      search_query += " AND organizations.target_school = 1 "
    end
    
    if (!@filters["neighborhood"].empty? rescue false)
      search_query += " AND locations.neighborhood LIKE :neighborhood "
      search_params = search_params.merge({ :neighborhood => @filters["neighborhood"] })
    elsif (!params["search"]["neighborhood"].empty? rescue false)
      search_query += " AND locations.neighborhood LIKE :neighborhood "
      search_params = search_params.merge({ :neighborhood => params["search"]["neighborhood"] })
    end
    
    if (!@filters["school_id"].empty? rescue false)
      search_query += " AND organizations.id = :school_id "
      search_params = search_params.merge({ :school_id => @filters["school_id"] })
    elsif (!params["search"]["school_id"].empty? rescue false)
      search_query += " AND organizations.id = :school_id "
      search_params = search_params.merge({ :school_id => params["search"]["school_id"] })
    end
    
    if !@filters["grade_ids"].nil?
      search_query += " AND pipeline_positions_grade_levels.id IN (:filter_grade_ids) "
      search_params = search_params.merge({ :filter_grade_ids => @filters["grade_ids"] })
    elsif !params["search"]["grade_ids"].nil? || !params["all_grades"] == 'all'
      search_query += " AND pipeline_positions_grade_levels.id IN (:grade_ids) "
      search_params = search_params.merge({ :grade_ids => params["search"]["grade_ids"] })
    end
    
    if !@filters["format_ids"].nil?
      search_query += " AND pipeline_positions_tutoring_types.id IN (:filter_format_ids) "
      search_params = search_params.merge({ :filter_format_ids => @filters["format_ids"] })
    elsif !params["search"]["format_ids"].nil? || !params["all_formats"] == 'all'
      search_query += " AND pipeline_positions_tutoring_types.id IN (:format_ids) "
      search_params = search_params.merge({ :format_ids => params["search"]["format_ids"] })
    end
    
    if !@filters["subject_ids"].nil?
      search_query += " AND pipeline_positions_subjects.id IN (:filter_subject_ids) "
      search_params = search_params.merge({ :filter_subject_ids => @filters["subject_ids"] })
    elsif !params["search"]["subject_ids"].nil? || !params["all_subjects"] == 'all'
      search_query += " AND pipeline_positions_subjects.id IN (:subject_ids) "
      search_params = search_params.merge({ :subject_ids => params["search"]["subject_ids"] })
    end
    
    if !@filters["language_ids"].nil?
      search_query += " AND pipeline_positions_language_spokens.id IN (:filter_language_ids) "
      search_params = search_params.merge({ :filter_language_ids => @filters["language_ids"] })
    elsif !params["search"]["language_ids"].nil? || !params["all_languages"] == 'all'
      search_query += " AND pipeline_positions_language_spokens.id IN (:language_ids) "
      search_params = search_params.merge({ :language_ids => params["search"]["language_ids"] })
    end
    
    params["search"]["time_frame"] = @filters["time_frame"] unless (@filters["time_frame"].nil? || @filters["time_frame"].empty?)
    if (!params["search"]["time_frame"].empty? rescue false)
      # after school
      if params["search"]["time_frame"] == "1"
        search_query += " AND HOUR(service_learning_position_times.start_time) > #{time_split} "
      # during school
      elsif params["search"]["time_frame"] == "2"
        search_query += " AND HOUR(service_learning_position_times.start_time) < #{(time_split+1)} "
      end
    end
    
    # add in a filter to only show approved positions
    search_query += " AND service_learning_positions.approved IS TRUE "
    # dont show self placements
    search_query += " AND service_learning_positions.self_placement IS NOT TRUE "
    
    search_query += " AND organization_quarters.unit_id = :unit_id "
    search_params = search_params.merge({ :unit_id => unit.id })
    
    return ServiceLearningPosition.find(:all, :include=>[{:organization_quarter=>{:organization=>:locations}},
                                                 :pipeline_positions_subjects,:pipeline_positions_grade_levels,
                                                 :pipeline_positions_tutoring_types, :pipeline_positions_language_spokens, :times], 
                                                 :conditions=>[search_query,search_params],
                                                 :order => "organizations.name")
  end
  
  def check_if_contact_info_is_current
    if @current_user && !@current_user.person.contact_info_updated_since(12.months.ago)
      flash[:notice] = "You haven't updated your contact information for awhile. Please confirm your contact information below."
      return redirect_to profile_path(:return_to => request.url)
    end
  end

  # This is only for UW Standard users since EXPO updates student info via Student Web Service directly
  # No need for external expo users since they need to fill contact information when creating accounts.
  def check_if_contact_info_blank
    if @current_user && @current_user.user_type == "UW Standard user" && @current_user.person.contact_info_updated_at.blank?
      flash[:notice] = "Please update your contact information."
      return redirect_to profile_path(:return_to => request.url)
    end
  end
  
end
