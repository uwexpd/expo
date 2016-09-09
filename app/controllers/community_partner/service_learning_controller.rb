class CommunityPartner::ServiceLearningController < CommunityPartnerController
  
  before_filter :fetch_unit  
  before_filter :add_service_learning_breadcrumbs
  # before_filter :check_moa_date_expiration, :except => [ 'moa_reminder', 'download_moa_pdf' ]
  
  before_filter :use_pipeline_links
  before_filter :fetch_quarter
  # before_filter :fetch_organization_quarter
  before_filter :fetch_organization_quarters
  before_filter :fetch_general_study
  
  
  def index
    @allow_evals = @organization_quarters.collect(&:allow_evals?).include?(true)
    @students = @organization_quarters.collect(&:students).flatten
    @positions = @organization_quarters.collect(&:positions).flatten.reject{|p|p.general_study? && !p.approved}
  end

  # Check Memorandum of Agreement (moa) for community partners
  def moa_reminder
    session[:breadcrumbs].add "Memorandum of Agreement"
    
    if request.post? && params[:commit]
          @current_user.person.update_attribute(:service_learning_moa_date, Time.now)
          redirect_to redirect_to_path and return
    end
  end
  
  def download_moa_pdf
    send_file 'files/uw_memorandum_of_agreement.pdf', :type=>"application/pdf"
  end
  

  protected
  
  def fetch_unit
    if params[:unit].nil? && session[:unit].nil?
      return redirect_to community_partner_home_path
    elsif !params[:unit].nil?
      session[:unit] = params[:unit]
      @unit = Unit.find params[:unit]
    end
    @unit ||= Unit.find(session[:unit]) rescue Unit.find_by_abbreviation("carlson")
  end
  
  def fetch_quarter
    @quarter = params[:quarter_abbrev].nil? ? Quarter.current_quarter : Quarter.find_by_abbrev(params[:quarter_abbrev])
  end
  
  def fetch_organization_quarters
    raise ExpoException.new("Your organization isn't marked active for any quarters.") and return if @organization.organization_quarters.empty?
    @organization_quarters = @organization.organization_quarters.for_quarter(@quarter)
    if @organization_quarters.empty?
      original_quarter = @quarter
      @quarter = @organization.organization_quarters.sort.last.quarter
      @organization_quarters = @organization.organization_quarters.for_quarter(@quarter)
      unless params[:quarter_abbrev].nil?
        flash.now[:error] = "Note: You are currently viewing #{@quarter.title} even though you requested to view #{original_quarter.title}.
                         We switched you to #{@quarter.quarter_code.name} because your organization is not marked as active for
                         #{original_quarter.quarter_code.name}. If you are trying to view information for #{original_quarter.title} instead,
                         please contact our staff for assistance."
      end
    end
    session[:breadcrumbs].add @quarter.title, community_partner_service_learning_home_url(@quarter)
  end
  
  # def fetch_organization_quarter
  #   raise ExpoException.new("Your organization isn't marked active for any quarters.") and return if @organization.organization_quarters.for_unit(@unit).empty?
  #   if @organization.active_for_quarter?(@quarter, @unit)
  #     @organization_quarter = @organization.organization_quarters.for_unit(@unit).select{|oq| oq.quarter.id == @quarter.id}.first
  #   else
  #     @organization_quarter = @organization.organization_quarters.for_unit(@unit).sort.last
  #     original_quarter = @quarter
  #     @quarter = @organization_quarter.quarter
  #     unless params[:quarter_abbrev].nil?
  #       flash.now[:error] = "Note: You are currently viewing #{@quarter.title} even though you requested to view #{original_quarter.title}.
  #                        We switched you to #{@quarter.quarter_code.name} because your organization is not marked as active for
  #                        #{original_quarter.quarter_code.name}. If you are trying to view information for #{original_quarter.title} instead,
  #                        please contact Carlson Center staff for assistance."
  #     end
  #   end
  #   session[:breadcrumbs].add @quarter.title, community_partner_service_learning_home_url(@quarter)
  # end
  
  def use_pipeline_links
    if @unit && @unit.abbreviation == "pipeline"
      @use_pipeline_links = true
    end
  end
  
  def fetch_general_study
    @general_study_positions = @quarter.service_learning_self_placements.select{|s|s.organization_id == "#{@organization.id}"}
    @general_study_positions = @general_study_positions.select{|s| s.general_study==true && !s.admin_approved? && (s.submitted? || s.supervisor_approved?) }
  end
    
  # An expiration date of August 1st each year for the academic year
  def check_moa_date_expiration #session[:vicarious_user].blank? &&
    if  @unit && @unit.abbreviation == "carlson" && (@current_user.person.service_learning_moa_date.nil? || @current_user.person.moa_expiration_date < Time.now )
      redirect_to community_partner_service_learning_moa_reminder_url(:return_to => request.request_uri) and return
    end
  end
  
    
  private

  def add_service_learning_breadcrumbs
   session[:breadcrumbs].add "Service-Learning", community_partner_service_learning_home_url(@quarter, :unit => @unit.id)
   @header_subtitle = "&raquo; Service-Learning Web Interface"
  end
    
  
end
