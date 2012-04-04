class Admin::MajorExtrasController < Admin::BaseController
  before_filter :add_major_extra_breadcrumbs

  def index
    @major_extras = MajorExtra.paginate(:page => params[:page], :order => 'discipline_category_id',:include => [:discipline_category])
	
    respond_to do |format|
      format.html # index.html.erb
	  format.xml  { render :xml => @major_extras }
    end
  end
 
  def show
    @major_extra = MajorExtra.find(params[:id])
    session[:breadcrumbs].add @major_extra.major ? @major_extra.major.title : @major_extra.fixed_name ? @major_extra.fixed_name : @major_extra.id
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @major_extra }
    end
  end
  
   def new
    @major_extra = MajorExtra.new
	
	@major_extra_major_ids = MajorExtra.all.collect{|m| m.major.id unless m.major.nil?}
	@majors = Major.find(:all, :conditions => {:major_last_yr => 9999}).reject{|m| @major_extra_major_ids.include? m.id }.sort_by(&:major_full_nm)
	
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @major_extra }
    end
  end
  
  def create
    @major_extra = MajorExtra.new(params[:major_extra])

    respond_to do |format|
      if @major_extra.save
        flash[:notice] = 'Major Extra was successfully created.'
        format.html { redirect_to(@major_extra) }
        format.xml  { render :xml => @major_extra, :status => :created, :location => @major_extra }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @major_extra.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @major_extra = MajorExtra.find(params[:id])
    session[:breadcrumbs].add "#{@major_extra.major ? @major_extra.major.title : @major_extra.fixed_name ? @major_extra.fixed_name : @major_extra.id}", major_extra_path(@major_extra)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @major_extra = MajorExtra.find(params[:id])

    respond_to do |format|
      if @major_extra.update_attributes(params[:major_extra])
        flash[:notice] = 'Major Extra was successfully updated.'
        format.html { redirect_to(@major_extra) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @major_extra.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit_discipline_category
	@major_extra = MajorExtra.find(params[:id])
	@discipline_category = DisciplineCategory.find(params[:discipline_category_id])
	
	@major_extra.update_attribute(:discipline_category, @discipline_category)
	
	respond_to do |format|
	  format.js
    end
  end
  
  def destroy
    @major_extra = MajorExtra.find(params[:id])
    @major_extra.destroy

    respond_to do |format|
      format.html { redirect_to(major_extras_url) }
      format.xml  { head :ok }
	  format.js
    end
  end
  
  protected
  
  def add_major_extra_breadcrumbs
    session[:breadcrumbs].add "Major Extras", :action => 'index'
  end
  
end