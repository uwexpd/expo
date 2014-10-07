class OpportunitiesController < ApplicationController
  skip_before_filter :login_required
        
  def form    
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
  
  def submit
    redirect_to :action => "form", :id => params[:id] if params[:commit] == "Back to edit"
    
    @research_opportunity ||= ResearchOpportunity.find(params[:id]) if params[:id]
    
    if @research_opportunity.nil?
      redirect_to :action => "form" and return
    end
    
    if params[:commit] == "Submit opportunity"
      if @research_opportunity.update_attribute :submitted, true          
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
      @research_opportunities = ResearchOpportunity.find_by_research_area(params[:research_area]).paginate unless params[:research_area].blank?
      @research_opportunities = ResearchOpportunity.find_by_keyword(params[:keyword]).paginate unless params[:keyword].blank?
      @research_opportunities = ResearchOpportunity.find_by_contact(params[:contact_person]).paginate unless params[:contact_person].blank?
      @total_found = @research_opportunities.size
    else
      @research_opportunities = ResearchOpportunity.paginate :order => 'created_at DESC, title ASC', :conditions => { :active => true }, :page => params[:page]
    end
  end
  
  def details
    if params[:id]
      @research_opportunity = ResearchOpportunity.find params[:id]
      unless @research_opportunity.active?
        flash[:error] = "The opportunity, #{@research_opportunity.title}, is inactive. You are not able to see the details."
        redirect_to :action => "search"
      end
    else
      flash[:error] = "Cannot find research opportunity id"
      redirect_to :back
    end
  end
         
end


