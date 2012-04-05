class Admin::OfferingsController < Admin::BaseController
  
  before_filter :add_offerings_breadcrumbs
  before_filter :check_user_unit, :except => [ :index, :auto_complete, :new, :create ]
  
  # GET /offerings
  # GET /offerings.xml
  def index
    @units = @current_user.units rescue []
    conditions = { :unit_id => @units.collect(&:id) }
    @offerings = Offering.paginate(:all, 
                                    :conditions => conditions, 
                                    :page => params[:page], 
                                    :include => [ :admin_phases ])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @offerings }
    end
  end

  def auto_complete
    @units = @current_user.units rescue []
    conditions = "unit_id IN (#{@units.collect(&:id).join(",")}) AND name LIKE '%#{params[:q]}%'"
    @offerings = Offering.find(:all,  :conditions => conditions,
                                  :include => [ :admin_phases ])
    
    respond_to do |format|
      format.js
    end
  end

  # GET /offerings/1
  # GET /offerings/1.xml
  def show
    @offering ||= Offering.find(params[:id])
    session[:breadcrumbs].add "#{@offering.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offering }
    end
  end

  # GET /offerings/new
  # GET /offerings/new.xml
  def new
    @offering = Offering.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @offering }
    end
  end

  # GET /offerings/1/edit
  def edit
    @offering ||= Offering.find(params[:id])
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
    session[:breadcrumbs].add "Edit"
  end

  # POST /offerings
  # POST /offerings.xml
  def create
    @offering = Offering.new(params[:offering])

    respond_to do |format|
      if @offering.save
        flash[:notice] = 'Offering was successfully created.'
        format.html { redirect_to(edit_offering_path(@offering, :anchor => "features")) }
        format.xml  { render :xml => @offering, :status => :created, :location => @offering }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /offerings/1
  # PUT /offerings/1.xml
  def update
    @offering ||= Offering.find(params[:id])

    respond_to do |format|
      if @offering.update_attributes(params[:offering])
        flash[:notice] = 'Offering was successfully updated.'
        format.html { redirect_to(@offering) }
        format.xml  { head :ok }
        format.js   { render :text => "Saved at #{Time.now.to_s(:time12)}." }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offering.errors, :status => :unprocessable_entity }
        format.js   { render :text => "Could not save offering.", :status => 409 }
      end
    end
  end

  # DELETE /offerings/1
  # DELETE /offerings/1.xml
  def destroy
    @offering ||= Offering.find(params[:id])
    @offering.destroy

    respond_to do |format|
      format.html { redirect_to(offerings_url) }
      format.xml  { head :ok }
    end
  end
  
  # PUT /offerings/1/clone
  def clone
    @offering ||= Offering.find(params[:id])
    
    if o2 = @offering.deep_clone!
      o2.update_attribute(:name, o2.name + " Copy")
      flash[:notice] = "Successfully cloned #{@offering.title}. You can customize the details below."
      redirect_to edit_offering_path(o2)
    else
      flash[:error] = "Sorry, but we couldn't copy that offering. An error occurred."
      redirect_to :back
    end
  end

  # PUT /offerings/1/toggle_features
  def toggle_features
    @offering ||= Offering.find(params[:id])

    respond_to do |format|
      if @offering.update_attributes(params[:offering])
        format.html { redirect_to(@offering) }
        format.js
      else
        format.html { render :action => "edit" }
        format.js   { |page| page.replace_html :features_save_failure_message, "Could not update features." }
      end
    end
  end
  
  
  protected
  
  def add_offerings_breadcrumbs
    session[:breadcrumbs].add "Offerings", offerings_url
  end

  def check_user_unit
    @offering = Offering.find(params[:offering_id] || params[:id])
    require_user_unit @offering.unit
  end
  
end
