class OpportunitiesController < ApplicationController
  skip_before_filter :login_required
  before_filter :redirect_to_new_site, :only => ['search', 'details']
  before_filter :student_login_required_if_possible, :only => ['search', 'details']
  before_filter :check_if_uwnetid, :only => ['search', 'details']
        
  def form
    redirect_to "https://new.expo.uw.edu/expo/opportunities/research"
    @research_opportunity = (ResearchOpportunity.find(params[:id]) if params[:id]) || ResearchOpportunity.new
    
    if @research_opportunity.submitted?
      flash[:notice] = "This research opportunity has been submitted."
      redirect_to :action => "submit", :id => @research_opportunity.id and return
    end
    
    if params[:research_opportunity]
      if @research_opportunity.update_attributes(params[:research_opportunity])
         redirect_to :action => "submit", :id => @research_opportunity.id
      end
    end
  end

  def update
    @research_opportunity = ResearchOpportunity.find(params[:id]) if params[:id]
    if params[:research_opportunity]
      if @research_opportunity.update_attributes(params[:research_opportunity])
         redirect_to :action => "submit", :id => @research_opportunity.id
      end
    end
  end
  
  def submit
    redirect_to :action => "form", :id => params[:id] if params[:form]
    redirect_to :action => "update", :id => params[:id] if params[:update]
    
    @research_opportunity ||= ResearchOpportunity.find(params[:id]) if params[:id]
    
    if @research_opportunity.nil?
      redirect_to :action => "form" and return
    end
    
    if params[:commit] == "Submit opportunity"
      if @research_opportunity.update_attributes(:submitted => true, :active => nil)
         flash[:notice] = "Successfully submitted a research opportunity."
         
         urp_template = EmailTemplate.find_by_name("research oppourtunity approval request")
         TemplateMailer.deliver(urp_template.create_email_to(@research_opportunity, "https://#{CONSTANTS[:base_url_host]}/admin/research_opportunities/#{@research_opportunity.id}", "urp@uw.edu")
                               ) if urp_template
      else
         flash[:error] = "Something went wrong. Unable to submit research opportunity. Please try again."
      end
    end     
  end  
  
  def search    
    if params[:research_area] || params[:keyword] || params[:contact_person]
      @research_opportunities = ResearchOpportunity.find_by_research_area(params[:research_area]) unless params[:research_area].blank?
      @research_opportunities = ResearchOpportunity.find_by_keyword(params[:keyword]) unless params[:keyword].blank?
      @research_opportunities = ResearchOpportunity.find_by_contact(params[:contact_person]) unless params[:contact_person].blank?
      @research_opportunities = @research_opportunities.select{|o| o.end_date.blank? || o.end_date > Date.today} unless @research_opportunities.blank?
      @total_found = @research_opportunities.size
      @research_opportunities = @research_opportunities.paginate(:page => params[:page], :per_page => 25)
      
    else
      @research_opportunities = ResearchOpportunity.paginate :order => 'created_at DESC, title ASC', 
                                                             :conditions => ["active =? AND (ISNULL(end_date) OR end_date >?)", true, Date.today], 
                                                             :page => params[:page]
    end
  end
  
  def details
    if params[:id]
      @research_opportunity = ResearchOpportunity.find params[:id]
      if !@research_opportunity.active? || (@research_opportunity.end_date && @research_opportunity.end_date < Date.today)
        flash[:error] = "The opportunity, #{@research_opportunity.title}, is inactive. You are not able to see the details."
        redirect_to :action => "search"
      end
    else
      flash[:error] = "Cannot find research opportunity id"
      redirect_to :back
    end
  end

  protected

  def redirect_to_new_site
    redirect_to "https://new.expo.uw.edu/expo/opportunities"
  end
  
  def check_if_uwnetid
    unless @current_user.class.name == "PubcookieUser"
      raise ExpoException.new("You need to have UW netid to access this page.",
          "Please make sure you click on the reb button, <strong>Sign in</strong>, in the login page to log in with your UW NetID. If you have any questions for accessing this page, please contact urp@uw.edu.")
    end
  end
         
end


