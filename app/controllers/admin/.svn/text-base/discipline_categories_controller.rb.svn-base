class Admin::DisciplineCategoriesController < Admin::BaseController
  before_filter :add_discipline_category_breadcrumbs

  def index
    @discipline_categories = DisciplineCategory.all.sort
	
    respond_to do |format|
      format.html # index.html.erb
	  format.xml  { render :xml => @discipline_categories }
    end
  end
 
  def show
    @discipline_category = DisciplineCategory.find_by_id(params[:id])
	  @unused_major_extras = MajorExtra.find(:all, :conditions => {:discipline_category_id => nil}).sort
    session[:breadcrumbs].add @discipline_category.name
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @discipline_category }
    end
  end
  
   def new
    @discipline_category = DisciplineCategory.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @discipline_category }
    end
  end
  
  def create
    @discipline_category = DisciplineCategory.new(params[:discipline_category])

    respond_to do |format|
      if @discipline_category.save
        flash[:notice] = 'Discipline Category was successfully created.'
        format.html { redirect_to(@discipline_category) }
        format.xml  { render :xml => @discipline_category, :status => :created, :location => @discipline_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @discipline_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @discipline_category = DisciplineCategory.find(params[:id])
    session[:breadcrumbs].add "#{@discipline_category.name}", discipline_category_path(@discipline_category)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @discipline_category = DisciplineCategory.find(params[:id])

    respond_to do |format|
      if @discipline_category.update_attributes(params[:discipline_category])
        flash[:notice] = 'Discipline Category was successfully updated.'
        format.html { redirect_to(@discipline_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @discipline_category.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @discipline_category = DisciplineCategory.find(params[:id])
    @discipline_category.destroy

    respond_to do |format|
      format.html { redirect_to(discipline_categories_url) }
      format.xml  { head :ok }
	  format.js
    end
  end
  
  def remove_major
	  @major_extra = MajorExtra.find_by_id(params[:major_extra_id])
    @major_extra.update_attribute(:discipline_category, nil)
	  @unused_major_extras = MajorExtra.find(:all, :conditions => {:discipline_category_id => nil}).sort
	
    respond_to do |format|
	    format.js
    end
  end
  
  def add_major
	  @major_extra = MajorExtra.find_by_id(params[:major_extra_id])
	  @discipline_category = DisciplineCategory.find(params[:id])
	  @major_extra.update_attribute(:discipline_category, @discipline_category)
	  @unused_major_extras = MajorExtra.find(:all, :conditions => {:discipline_category_id => nil}).sort
	
	  respond_to do |format|
	    format.js
    end
  end
  
  protected
  
  def add_discipline_category_breadcrumbs
    session[:breadcrumbs].add "Discipline Categories", :action => 'index'
  end
  
end