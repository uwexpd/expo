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
     @research_opportunities = ResearchOpportunity.find(:all, :conditions => ['email = ?', params[:search][:email]]) unless params[:search][:email].blank?
     # conditions = params[:search] ? ["login LIKE ?", "%#{params[:search][:login]}%"] : nil
     # @users = User.paginate :all, :order => 'identity_type DESC, login ASC', 
     #                         :conditions => conditions, 
     #                         :page => params[:page], :include => [:person, :latest_login]
     
     @research_opportunities = ResearchOpportunity.find(:all, :conditions => ["title LIKE ?", "%#{params[:search][:title]}%"])unless params[:search][:title].blank?

     if @research_opportunities.empty?
       flash[:error] = "Can not find the research opportunity with your search input."
       redirect_to :action => "index" and return
     end
     @research_opportunities = @research_opportunities.paginate(:page => params[:page], :per_page => 25)
     render :action => "index"
   end

   def active
     @research_opportunity = ResearchOpportunity.find(params[:id])
     @research_opportunity.update_attribute :active, !@research_opportunity.active?
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
