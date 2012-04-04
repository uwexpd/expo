class Users::EmailAddressesController < ApplicationController

  layout 'welcome'

  def index
    @email_addresses = @current_user.email_addresses.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @email_addresses }
    end
  end

  def new
    @email_address = @current_user.email_addresses.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_address }
    end
  end

  def edit
    @email_address = @current_user.email_addresses.find(params[:id])
    session[:breadcrumbs].add "#{@email_address.to_header}", @email_address
    session[:breadcrumbs].add "Edit"
  end

  def create
    @email_address = @current_user.email_addresses.new(params[:email_address])

    respond_to do |format|
      if @email_address.save
        flash[:notice] = "E-mail address was successfully created."
        format.html { redirect_to users_email_addresses_path }
        format.xml  { render :xml => @email_address, :status => :created, :location => users_email_addresses_path }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_address.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    @email_address = @current_user.email_addresses.find(params[:id])

    respond_to do |format|
      if @email_address.update_attributes(params[:email_address])
        flash[:notice] = "#{@email_address.to_header} was successfully updated."
        format.html { redirect_to users_email_addresses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @email_address = @current_user.email_addresses.find(params[:id])
    @email_address.destroy

    respond_to do |format|
      format.html { redirect_to users_email_addresses_url }
      format.xml  { head :ok }
    end
  end

end