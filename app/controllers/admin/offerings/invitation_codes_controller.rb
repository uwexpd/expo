class Admin::Offerings::InvitationCodesController < Admin::OfferingsController

  before_filter :fetch_offering
  before_filter :add_invitation_codes_breadcrumbs
  
  def index
    @invitation_codes = @offering.invitation_codes.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invitation_codes }
    end
  end
    
  def show
    @invitation_code = @offering.invitation_codes.find(params[:id])
    session[:breadcrumbs].add "#{@invitation_code.code}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invitation_code }
    end
  end
  
  def new
    @invitation_code = @offering.invitation_codes.new
	@invitation_code.code = OfferingInvitationCode.random_string
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invitation_code }
    end
  end
  
  def generate
	
	number_to_generate = params[:number_to_generate].to_i
	institution_id = params[:institution_id].to_i if params[:institution_id].to_i > 0
	
	respond_to do |format|
		if number_to_generate > 0
			OfferingInvitationCode.generate(@offering, number_to_generate, institution_id)
			flash[:notice] = "Codes generated."
			format.html { redirect_to offering_invitation_codes_path(@offering) }
		else
			flash[:error] = "You must specify an amount greater than Zero"
			format.html { redirect_to offering_invitation_codes_path(@offering) }
		end
	end
  end
  
  
  def create

	@invitation_code = @offering.invitation_codes.new(params[:invitation_code])

	respond_to do |format|
	  if @invitation_code.save
		flash[:notice] = "Successfully created invitation code."
		format.html { redirect_to offering_invitation_code_path(@offering, @invitation_code) }
		format.xml  { render :xml => @invitation_code, :status => :created, 
							 :location => offering_invitation_code_path(@offering, @invitation_code) }
	  else
		format.html { render :action => "new" }
		format.xml  { render :xml => @invitation_code.errors, :status => :unprocessable_entity }
	  end
	end

  end
  
  def edit
    @invitation_code = @offering.invitation_codes.find(params[:id])
    session[:breadcrumbs].add "#{@invitation_code.code}", offering_invitation_code_path(@offering, @invitation_code)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @invitation_code = @offering.invitation_codes.find(params[:id])

    respond_to do |format|
      if @invitation_code.update_attributes(params[:invitation_code])
        flash[:notice] = "Successfully updated invitation code."
        format.html { redirect_to offering_invitation_code_path(@offering, @invitation_code) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invitation_code.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @invitation_code = @offering.invitation_codes.find(params[:id])
    @invitation_code.destroy
    flash[:notice] = "Successfully destroyed invitation code."
    respond_to do |format|
      format.html { redirect_to offering_invitation_codes_url(@offering) }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def fetch_offering
    @offering = Offering.find params[:offering_id]
    session[:breadcrumbs].add "#{@offering.title}", offering_path(@offering)
  end

  def add_invitation_codes_breadcrumbs
    session[:breadcrumbs].add "Invitation Codes", offering_invitation_codes_path(@offering)
  end

end
