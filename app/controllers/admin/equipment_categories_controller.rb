class Admin::EquipmentCategoriesController < Admin::BaseController

  before_filter :add_equipment_categories_breadcrumbs

  uses_tiny_mce
  
  def index
    @equipment_categories = EquipmentCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @equipment_categories }
    end
  end
    
  def show
    @equipment_category = EquipmentCategory.find(params[:id])
    session[:breadcrumbs].add "#{@equipment_category.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @equipment_category }
    end
  end
  
  def new
    @equipment_category = EquipmentCategory.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @equipment_category }
    end
  end
  
  def create
    @equipment_category = EquipmentCategory.new(params[:equipment_category])

    respond_to do |format|
      if @equipment_category.save
        flash[:notice] = "Successfully created equipment category."
        format.html { redirect_to @equipment_category }
        format.xml  { render :xml => @equipment_category, :status => :created, 
                             :location => @equipment_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @equipment_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @equipment_category = EquipmentCategory.find(params[:id])
    session[:breadcrumbs].add "#{@equipment_category.title}", @equipment_category
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @equipment_category = EquipmentCategory.find(params[:id])

    respond_to do |format|
      if @equipment_category.update_attributes(params[:equipment_category])
        flash[:notice] = "Successfully updated equipment category."
        format.html { redirect_to @equipment_category }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @equipment_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @equipment_category = EquipmentCategory.find(params[:id])
    @equipment_category.destroy
    flash[:notice] = "Successfully destroyed equipment category."
    respond_to do |format|
      format.html { redirect_to equipment_categories_url }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def add_equipment_categories_breadcrumbs
    session[:breadcrumbs].add "Equipment", equipments_path
    session[:breadcrumbs].add "Categories", equipment_categories_path
  end

end
