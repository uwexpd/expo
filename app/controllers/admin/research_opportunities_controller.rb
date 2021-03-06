class Admin::ResearchOpportunitiesController < Admin::BaseController
  
  before_filter :add_research_opportunities_breadcrumbs

   def index
     @research_opportunities = ResearchOpportunity.paginate :order => 'created_at DESC, title ASC', :page => params[:page]

     respond_to do |format|
       format.html # index.html.erb
       format.xml  { render :xml => @research_opportunities }
     end
   end

   def show
     @research_opportunity = ResearchOpportunity.find(params[:id])
     session[:breadcrumbs].add "#{@research_opportunity.title}"

     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @research_opportunity }
     end
   end

   def new
     @research_opportunity = ResearchOpportunity.new
     session[:breadcrumbs].add "New"

     respond_to do |format|
       format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
       format.xml  { render :xml => @research_opportunity }
     end
   end

   def create
     @research_opportunity = ResearchOpportunity.new(params[:research_opportunity])

     respond_to do |format|
       if @research_opportunity.save
         flash[:notice] = "Successfully created a research opportunity."
         format.html { redirect_to research_opportunity_path(@research_opportunity) }
         format.xml  { render :xml => @research_opportunity, :status => :created, 
                              :location => research_opportunity_path(@research_opportunity) }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @research_opportunity.errors, :status => :unprocessable_entity }
       end
     end
   end

   def edit
     @research_opportunity = ResearchOpportunity.find(params[:id])
     session[:breadcrumbs].add "#{@research_opportunity.title}", research_opportunity_path(@research_opportunity)
     session[:breadcrumbs].add "Edit"
   end

   def update
     @research_opportunity = ResearchOpportunity.find(params[:id])

     respond_to do |format|
       if @research_opportunity.update_attributes(params[:research_opportunity])
         flash[:notice] = "Successfully updated research opportunity ."
         format.html { redirect_to research_opportunity_path(@research_opportunity) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @research_opportunity.errors, :status => :unprocessable_entity }
       end
     end
   end

   def destroy
     @research_opportunity = ResearchOpportunity.find(params[:id])
     @research_opportunity.destroy
     flash[:notice] = "Successfully deleted this research opportunity."
     respond_to do |format|
       format.html { redirect_to research_opportunities_path }
       format.xml  { head :ok }
       format.js
     end
   end

   def search
     session[:breadcrumbs].add "Search"
     @research_opportunities = ResearchOpportunity.find_by_research_area(params[:research_area], false) unless params[:research_area].blank?
     @research_opportunities = ResearchOpportunity.find_by_keyword(params[:keyword].strip, false) unless params[:keyword].blank?
     @research_opportunities = ResearchOpportunity.find_by_contact(params[:contact_person].strip, false) unless params[:contact_person].blank?
     @total_found = @research_opportunities.size
     
     if @research_opportunities.empty?
       flash[:error] = "Can not find any research opportunities with your search input."
       redirect_to :action => "index" and return
     end
     @research_opportunities = @research_opportunities.paginate(:page => params[:page], :per_page => 25)
     render :action => "index"
   end

   def active
     @research_opportunity = ResearchOpportunity.find(params[:id])
     @research_opportunity.update_attribute :active, !@research_opportunity.active?
     
     faculty_template = EmailTemplate.find_by_name("research oppourtunity activate and deactivate notification")
     link = @research_opportunity.active? ? "https://#{CONSTANTS[:base_url_host]}/opportunities/details/#{@research_opportunity.id}" : "https://#{CONSTANTS[:base_url_host]}/opportunities/submit/#{@research_opportunity.id}"
     #TemplateMailer.deliver(faculty_template.create_email_to(@research_opportunity, link, @research_opportunity.email)) if faculty_template
     EmailQueue.queue(@research_opportunity.email, faculty_template.create_email_to(@research_opportunity, link, @research_opportunity.email)) if faculty_template
     
     respond_to do |format|
       format.html { redirect_to redirect_to_path || {:action => "show"} }
       format.js
     end
   end

   def removed
     @research_opportunity = ResearchOpportunity.find(params[:id])
     @research_opportunity.update_attribute :removed, !@research_opportunity.removed?
     respond_to do |format|
       format.html { redirect_to redirect_to_path || {:action => "show"} }
       format.js
     end
   end
         
   protected

   def add_research_opportunities_breadcrumbs
     session[:breadcrumbs].add "Research Opportunities", research_opportunities_path
   end     
  
end
