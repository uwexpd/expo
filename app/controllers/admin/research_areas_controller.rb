class Admin::ResearchAreasController < Admin::BaseController

  before_filter :add_research_areas_breadcrumbs
  
  def index
    @research_areas = ResearchArea.all.sort_by(&:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @research_areas }
    end
  end
    
  def show
    @research_area = ResearchArea.find(params[:id])
    session[:breadcrumbs].add "#{@research_area.name}"
	
	  @new_select_value = { :value => @research_area.id, :name => @research_area.name }
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @research_area }
    end
  end
  
  def new
    @research_area = ResearchArea.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html { render :layout => "popup" if params[:popup_layout] }# new.html.erb
      format.xml  { render :xml => @research_area }
    end
  end
  
  def create
    @research_area = ResearchArea.new(params[:research_area])

    respond_to do |format|
      if @research_area.save
        flash[:notice] = "Successfully created research area."
        format.html { redirect_to research_area_path(@research_area) }
        format.xml  { render :xml => @research_area, :status => :created, 
                             :location => research_area_path(@research_area) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @research_area.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @research_area = ResearchArea.find(params[:id])
    session[:breadcrumbs].add "#{@research_area.name}", research_area_path(@research_area)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @research_area = ResearchArea.find(params[:id])

    respond_to do |format|
      if @research_area.update_attributes(params[:research_area])
        flash[:notice] = "Successfully updated research area."
        format.html { redirect_to research_area_path(@research_area) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @research_area.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @research_area = ResearchArea.find(params[:id])
    @research_area.destroy
    flash[:notice] = "Successfully destroyed research area."
    respond_to do |format|
      format.html { redirect_to research_area_path }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def add_research_areas_breadcrumbs
    session[:breadcrumbs].add "Research Area", research_areas_path
  end
end