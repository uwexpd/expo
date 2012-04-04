class Admin::Offerings::ReviewCriterionsController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_review_criterions_breadcrumbs
  
  def index
    @review_criterions = @offering.review_criterions.find(:all, :order => 'sequence')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @review_criterions }
    end
  end
    
  def show
    @review_criterion = @offering.review_criterions.find(params[:id])
    session[:breadcrumbs].add "#{@review_criterion.title}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @review_criterion }
    end
  end
  
  def new
    @review_criterion = @offering.review_criterions.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @review_criterion }
    end
  end
  
  def create
    @review_criterion = @offering.review_criterions.new(params[:review_criterion])

    respond_to do |format|
      if @review_criterion.save
        flash[:notice] = "Successfully created review criterion."
        format.html { redirect_to offering_review_criterion_path(@offering, @review_criterion) }
        format.xml  { render :xml => @review_criterion, :status => :created, 
                             :location => offering_review_criterion_path(@offering, @review_criterion) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @review_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @review_criterion = @offering.review_criterions.find(params[:id])
    session[:breadcrumbs].add "#{@review_criterion.title}", offering_review_criterion_path(@offering, @review_criterion)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @review_criterion = @offering.review_criterions.find(params[:id])

    respond_to do |format|
      if @review_criterion.update_attributes(params[:review_criterion])
        flash[:notice] = "Successfully updated review criterion."
        format.html { redirect_to offering_review_criterion_path(@offering, @review_criterion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @review_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @review_criterion = @offering.review_criterions.find(params[:id])
    @review_criterion.destroy
    flash[:notice] = "Successfully destroyed review criterion."
    respond_to do |format|
      format.html { redirect_to offering_review_criterions_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_review_criterions_breadcrumbs
    session[:breadcrumbs].add "Review Criteria", offering_review_criterions_path(@offering)
  end

end
