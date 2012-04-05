class Admin::Offerings::PagesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_pages_breadcrumbs
  
  # GET /pages
  # GET /pages.xml
  def index
    @pages = @offering.pages.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = @offering.pages.find(params[:id])
    session[:breadcrumbs].add "#{@page.title}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = @offering.pages.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = @offering.pages.find(params[:id])
    session[:breadcrumbs].add "#{@page.title}", offering_page_path(@offering, @page)
    session[:breadcrumbs].add "Edit"
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = @offering.pages.new(params[:page])

    respond_to do |format|
      if @page.save
        flash[:notice] = 'OfferingPage was successfully created.'
        format.html { redirect_to offering_page_url(@offering, @page) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = @offering.pages.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'OfferingPage was successfully updated.'
        format.html { redirect_to offering_page_url(@offering, @page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = @offering.pages.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to offering_pages_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end
  
  def sort
    params[:pages].each_with_index do |id, index|
      @offering.pages.update_all(['ordering=?', index+1], ['id=?', id])
    end
    respond_to do |format|
      format.js   { render :text => "OK", :status => 200 }
    end
  end
  
  
  protected
  
  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end
  
  def add_pages_breadcrumbs
    session[:breadcrumbs].add "Pages &amp; Questions", offering_pages_path(@offering)
  end
  
end
