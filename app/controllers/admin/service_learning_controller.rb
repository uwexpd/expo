class Admin::ServiceLearningController < Admin::BaseController
  before_filter :fetch_unit
  before_filter :check_unit_permission
  before_filter :service_learning_breadcrumbs
  before_filter :fetch_quarter, :except => [:hide_change_log, :mid_quarter_email_links]
  #before_filter :check_if_pipeline

  def index
    session[:breadcrumbs].add "Home"
    @show_quarter_select_dropdown = true
  end
  
  def hide_change_log
    session[:show_change_log_after] = Time.now
    render :nothing => true
  end
  
  def mid_quarter
    render :partial => "mid_quarter_email_links" and return if params[:links]
    @orgs = {}

    @organization_quarters = @quarter.organization_quarters.reject{|oq| oq.organization.active_for_quarter?(@quarter.next, @unit) || oq.organization.inactive? || oq.unit != @unit}
    @organization_quarters = @organization_quarters.sort_by(&:organization)
    @orgs[:with_all]              = @organization_quarters.select{|oq| !oq.placements.filled.empty? }
    @orgs[:self_placements_only]  = @orgs[:with_all].select{|oq| oq.self_placements_only? }
    @orgs[:with]                  = @orgs[:with_all].select{|oq| !oq.self_placements_only? }
    @orgs[:without]               = @organization_quarters.select{|oq| oq.placements.filled.empty? }
    @orgs[:inactive_until_next]   = Organization.find(:all, :conditions => { :next_active_quarter_id => @quarter.next }).reject{|o| o.active_for_quarter?(@quarter.next, @unit) || !o.inactive?}
    
    if params[:select]
      @new_quarter = @quarter.next
      params[:select].each do |obj_type,obj_hash|
        obj_hash.each do |obj_id,val|
          if obj_type == "Organization"
            o = Organization.find(obj_id)
            o.invite_for(@quarter.next)
          else
            oq = OrganizationQuarter.find(obj_id)          
            oq.allow_evals_if_active
            oq.queue_mid_quarter_emails(val, @unit)
          end
        end
      end
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_communicate_email_queue_index_url and return if EmailQueue.messages_waiting?
      redirect_to :back
    end
    session[:breadcrumbs].add "Mid-Quarter Check-in"
  end

  def students
     @service_learning_students ||= @quarter.service_learning_courses.for_unit(@unit).collect(&:enrollees).flatten.compact.sort
     @students = @service_learning_students.paginate(:page => params[:page], :per_page => 20)
    session[:breadcrumbs].add "Students"
  end
  
  def placements
    @carlson_placements = @quarter.service_learning_placements.select{|p| p.unit_id == @unit.id && p.filled?}
    session[:breadcrumbs].add "Placements"
  end
  
  protected

  def fetch_quarter
    @quarter = (params[:quarter_abbrev] ? Quarter.find_by_abbrev(params[:quarter_abbrev]) : Quarter.current_quarter) || Quarter.current_quarter
    session[:breadcrumbs].add "#{@quarter.title}", service_learning_home_path(@unit, @quarter), :class => 'quarter_select'
  end

  def service_learning_breadcrumbs
    session[:breadcrumbs].add @unit.name, service_learning_home_path(@unit, nil)
  end
  
  def fetch_unit
    @unit = params[:unit] ? Unit.find_by_abbreviation(params[:unit]) : Unit.find_by_abbreviation("carlson")
    
    # see if the units is nil, if so see if it was a quarter abbrev, if so redirect to unit of carlson
    if @unit.nil? && !params[:unit].match(/\D\D\D\d\d\d\d/).nil?
      flash[:error] = "No unit abbreviation was included in the URL. You have been redirected to Carlson's Service Learning module."
      return redirect_to service_learning_home_path("carlson", params[:unit])
    end
    
    @unit_abbrev = @unit.abbreviation
    
    @use_pipeline_links = true if @unit_abbrev == "pipeline"
  end

  def check_unit_permission
    require_user_unit @unit
  end
  
=begin
  def check_if_pipeline
    if params[:from_pipeline]
      ### very basic redirecting of the service learning links 
      service_learning_uri = request.request_uri
      pipeline_uri = service_learning_uri.gsub("service_learning","pipeline")
      redirect_to pipeline_uri
    end
  end
=end
end
