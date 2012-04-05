class Admin::Populations::ConditionsController < Admin::PopulationsController

  before_filter :fetch_population
  before_filter :add_conditions_breadcrumbs
  
  def index
    @conditions = @population.conditions.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @conditions }
    end
  end
    
  def show
    @condition = @population.conditions.find(params[:id])
    session[:breadcrumbs].add "#{@condition.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @condition }
    end
  end
  
  def new
    @condition = @population.conditions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @condition }
    end
  end
  
  def create
    @condition = @population.conditions.new(params[:condition])

    respond_to do |format|
      if @condition.save
        flash[:notice] = "Successfully created condition."
        format.html { redirect_to population_condition_path(@population, @condition) }
        format.xml  { render :xml => @condition, :status => :created, 
                             :location => population_condition_path(@population, @condition) }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @condition.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end
  
  def edit
    @condition = @population.conditions.find(params[:id])
    session[:breadcrumbs].add "#{@condition.title}", population_condition_path(@population, @condition)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @condition = @population.conditions.find(params[:id])

    respond_to do |format|
      if @condition.update_attributes(params[:condition])
        flash[:notice] = "Successfully updated condition."
        format.html { redirect_to population_condition_path(@population, @condition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @condition.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @condition = @population.conditions.find(params[:id])
    @condition.destroy
    flash[:notice] = "Successfully destroyed condition."
    respond_to do |format|
      format.html { redirect_to population_conditions_url(@population) }
      format.xml  { head :ok }
      format.js
    end
  end

  def refresh_dropdowns
    if params[:id] == 'new'
      @condition = @population.conditions.new(params[:population][:condition_attributes].first)
    else
      @condition = @population.conditions.find(params[:id])
      @condition.update_attributes(params[:population][:condition_attributes][@condition.id.to_s])
    end
    respond_to do |format|
      format.js
    end
  end

  protected

  def fetch_population
    @population = Population.find params[:population_id]
    session[:breadcrumbs].add "#{@population.title}", population_path(@population)
  end

  def add_conditions_breadcrumbs
    session[:breadcrumbs].add "Conditions", population_conditions_path(@population)
  end

end
