class Admin::UnitsController < Admin::BaseController
  before_filter :add_units_breadcrumbs
  before_filter :check_role_permission, :except => [:index]
  before_filter :check_unit_permission, :only => [:show, :update, :edit, :destroy]
  
  def index
    @units = Unit.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @units }
    end
  end
    
  def show
    @unit ||= Unit.find_by_abbreviation(params[:id])
    session[:breadcrumbs].add "#{@unit.name}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @unit }
    end
  end
  
  def new
    @unit = Unit.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @unit }
    end
  end
  
  def create
    @unit = Unit.new(params[:unit])

    respond_to do |format|
      if @unit.save
        flash[:notice] = "Successfully created unit."
        format.html { redirect_to @unit }
        format.xml  { render :xml => @unit, :status => :created, 
                             :location => @unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @unit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @unit ||= Unit.find_by_abbreviation(params[:id])
    session[:breadcrumbs].add "#{@unit.name}", @unit
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @unit ||= Unit.find_by_abbreviation(params[:id])

    respond_to do |format|
      if @unit.update_attributes(params[:unit])
        flash[:notice] = "Successfully updated unit."
        format.html { redirect_to @unit }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @unit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @unit ||= Unit.find_by_abbreviation(params[:id])
    @unit.destroy
    flash[:notice] = "Successfully destroyed unit."
    respond_to do |format|
      format.html { redirect_to units_url }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def add_units_breadcrumbs
    session[:breadcrumbs].add "Units", units_path
  end
  
  def check_role_permission
    check_permission(:unit_manager)
  end

  def check_unit_permission
    @unit = Unit.find_by_abbreviation(params[:id])
    unless @current_user.has_role?(:unit_manager, @unit)
      return render :template => "exceptions/wrong_unit", :status => :unauthorized
    end
    
  end

end
