class Admin::Committees::QuartersController < Admin::CommitteesController
  
  before_filter :fetch_committee, :add_committee_quarters_breadcrumbs

  def index
    @quarters = @committee.committee_quarters.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quarters }
    end
  end

  def show
    @quarter = @committee.committee_quarters.find(params[:id])
    session[:breadcrumbs].add "#{@quarter.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @quarter }
    end
  end

  def new
    @quarter = @committee.committee_quarters.build
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @quarter }
    end
  end

  def edit
    @quarter = @committee.committee_quarters.find(params[:id])
    session[:breadcrumbs].add "#{@quarter.title}", admin_committee_quarter_path(@committee, @quarter)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @quarter = @committee.committee_quarters.build(params[:committee_quarter])

    respond_to do |format|
      if @quarter.save
        flash[:notice] = 'CommitteeQuarter was successfully created.'
        format.html { redirect_to(admin_committee_quarter_url(@committee, @quarter)) }
        format.xml  { render :xml => @quarter, :status => :created, :location => @quarter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @quarter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @quarter = @committee.committee_quarters.find(params[:id])

    respond_to do |format|
      if @quarter.update_attributes(params[:committee_quarter])
        flash[:notice] = 'CommitteeQuarter was successfully updated.'
        format.html { redirect_to(admin_committee_quarter_url(@committee, @quarter)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quarter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @quarter = @committee.committee_quarters.find(params[:id])
    @quarter.destroy

    respond_to do |format|
      format.html { redirect_to(admin_committee_quarters_url(@committee)) }
      format.xml  { head :ok }
    end
  end


  protected
  
  def fetch_committee
    @committee = Committee.find(params[:committee_id])
  end

  def add_committee_quarters_breadcrumbs
    session[:breadcrumbs].add @committee.name, admin_committee_path(@committee)
    session[:breadcrumbs].add "Quarters", admin_committee_quarters_path(@committee)
  end
    
end
