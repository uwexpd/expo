class Admin::QuotesController < Admin::BaseController
  before_filter :add_quotes_breadcrumbs
  
  def index
    @quotes = Quote.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quotes }
    end
  end
    
  def show
    @quote = Quote.find(params[:id])
    session[:breadcrumbs].add "#{@quote.id.to_s}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @quote }
    end
  end
  
  def new
    @quote = Quote.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @quote }
    end
  end
  
  def create
    @quote = Quote.new(params[:quote])

    respond_to do |format|
      if @quote.save
        flash[:notice] = "Successfully created quote."
        format.html { redirect_to @quote }
        format.xml  { render :xml => @quote, :status => :created, 
                             :location => @quote }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @quote.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @quote = Quote.find(params[:id])
    session[:breadcrumbs].add "#{@quote.id.to_s}", @quote
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @quote = Quote.find(params[:id])

    respond_to do |format|
      if @quote.update_attributes(params[:quote])
        flash[:notice] = "Successfully updated quote."
        format.html { redirect_to @quote }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quote.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @quote = Quote.find(params[:id])
    @quote.destroy
    flash[:notice] = "Successfully destroyed quote."
    respond_to do |format|
      format.html { redirect_to quotes_url }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def add_quotes_breadcrumbs
    session[:breadcrumbs].add "Quotes", quotes_path
  end
  
end