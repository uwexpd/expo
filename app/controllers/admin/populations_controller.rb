class Admin::PopulationsController < Admin::BaseController

  before_filter :add_populations_breadcrumbs
  
  def index
    populate_vars_by_access_level

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @populations }
    end
  end

  def deleted
    session[:breadcrumbs].add "Deleted"
    @populations = Population.deleted
  end
    
  def show
    @population = Population.find(params[:id])
    @objects = @population.objects
    session[:breadcrumbs].add "#{@population.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @population }
      format.xls { 
        if @population.output_fields.blank?
          flash[:error] = "Before downloading the Excel output for this query, please select the fields to include in the ouput."
          redirect_to :action => "output"
        else
          render :action => 'show', :layout => 'basic' 
        end
      }
    end
  end
  caches_action :show, :if => Proc.new { |c| c.request.format == :xls } # Only cache the XLS version
  
  def new
    @population = Population.new(:access_level => 'creator')
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @population }
    end
  end
  
  def create
    @population = Population.new(params[:population])

    respond_to do |format|
      if @population.save
        flash[:notice] = "Successfully created query."
        format.html { redirect_to edit_population_path(@population) }
        format.xml  { render :xml => @population, :status => :created, 
                             :location => edit_population_path(@population) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @population.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @population = Population.find(params[:id])
    populate_vars_by_access_level
    
    session[:breadcrumbs].add "#{@population.title}", population_path(@population)
    session[:breadcrumbs].add "Edit"
  end

  def output
    @population = Population.find(params[:id])
    @objects = @population.objects
    session[:breadcrumbs].add "#{@population.title}", population_path(@population)
    session[:breadcrumbs].add "Edit Output"
  end
  
  def update
    @population = Population.find(params[:id])
    @population.attributes = params[:population]
    @population.system = false # If the user is editing the population, it is no longer a "system" population.
    @population.custom_query = nil if params[:use_custom_query] != "true" || !@current_user.has_role?(:custom_query_writer)
    session[:breadcrumbs].add "#{@population.title}"
    
    respond_to do |format|
      if @population.save && @population.reload
        begin
          @population.generate_objects!
        rescue
          if @population.custom_query?
            @population.errors.add_to_base "Your custom query is not valid. Please try again or select a starting set instead."
          else
            @population.errors.add_to_base "There was an error while generating your query."
          end
          return render :action => 'edit'
        end
        expire_action :action => 'show', :format => :xls
        expire_action :controller => 'stats', :action => 'population'

        flash[:notice] = "Successfully updated query."
        format.html { redirect_to population_path(@population) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @population.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @population = Population.find(params[:id])
    @population.destroy
    flash[:notice] = "Successfully deleted query. 
                    #{@template.link_to("Undo", undestroy_population_path(@population), :method => :delete)}."
    respond_to do |format|
      format.html { redirect_to populations_url }
      format.xml  { head :ok }
    end
  end

  def undestroy
    @population = Population.find_with_deleted(params[:id])
    @population.undestroy
    flash[:notice] = "Successfully restored destroyed query."
    respond_to do |format|
      format.html { redirect_to population_url(@population) }
      format.xml  { head :ok }
    end
  end

  def regenerate
    @population = Population.find(params[:id])
    @population.generate_objects!
    expire_action :action => 'show', :format => :xls
    expire_action :controller => 'stats', :action => 'population'
    flash[:notice] = "Successfully regenerated query results."
    respond_to do |format|
      format.html { redirect_to population_url(@population) }
      format.js
    end
  end

  def save_output_fields
    @population = Population.find(params[:id])
    @population.update_attribute(:output_fields, params[:output_fields])
    expire_action :action => 'show', :format => :xls
    respond_to do |format|
      format.js { render :text => "<span class=\"icon-left ok green\" style=\"font-size:100%\">Saved</span>" }
    end
  end

  def refresh_dropdowns
    @population = Population.find params[:id]
    @population.update_attributes(params[:population])
    
    populate_vars_by_access_level
    
    respond_to do |format|
      format.js
    end
  end

  def clone
    @population ||= Population.find(params[:id])
    
    if p2 = @population.clone!
      flash[:notice] = "Successfully cloned #{@population.title} to #{p2.title}."
      redirect_to edit_population_url(p2)
    else
      flash[:error] = "Sorry, but we couldn't copy that population. An error occurred."
      redirect_to :back
    end
  end


  def objects
    @population = Population.find params[:id]
    @objects = @population.objects
    session[:breadcrumbs].add "#{@population.title}", population_path(@population)
    session[:breadcrumbs].add "Results"
    
    respond_to do |format|
      format.html
      format.js { 
        if @population.output_fields.blank?
          render :partial => "objects"
        else
          redirect_to :action => :show, :format => :xls, :layout => 'basic'
        end
      }
    end
  end

  protected

  def add_populations_breadcrumbs
    session[:breadcrumbs].add "Queries", populations_path
  end

  def populate_vars_by_access_level
    @user_populations = Population.creator(@current_user).user_created # + PopulationGroup.creator(@current_user)
    @unit_populations = Population.unit(@current_user).user_created # + PopulationGroup.unit(@current_user)
  	@everyone_populations = Population.everyone.user_created # + PopulationGroup.everyone
  end

end
