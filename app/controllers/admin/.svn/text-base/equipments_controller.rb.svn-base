class Admin::EquipmentsController < Admin::BaseController

  before_filter :add_equipment_breadcrumbs

  uses_tiny_mce
  
  def index
    @equipments = Equipment.find :all, :include => :category, :order => 'staff_only DESC, equipment_category_id'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @equipment }
    end
  end
    
  def show
    @equipment = Equipment.find(params[:id])
    session[:breadcrumbs].add "#{@equipment.title} (#{@equipment.category.try(:title)})"
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @equipment }
    end
  end
  
  def new
    @equipment = Equipment.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @equipment }
    end
  end
  
  def create
    @equipment = Equipment.new(params[:equipment])

    respond_to do |format|
      if @equipment.save
        flash[:notice] = "Successfully created equipment."
        format.html { redirect_to equipment_path(@equipment) }
        format.xml  { render :xml => @equipment, :status => :created, 
                             :location => equipment_path(@equipment) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @equipment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @equipment = Equipment.find(params[:id])
    session[:breadcrumbs].add "#{@equipment.title}", equipment_path(@equipment)
    session[:breadcrumbs].add "Edit"
  end
  
  def update
    @equipment = Equipment.find(params[:id])

    respond_to do |format|
      if @equipment.update_attributes(params[:equipment])
        flash[:notice] = "Successfully updated equipment."
        format.html { redirect_to equipment_path(@equipment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @equipment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @equipment = Equipment.find(params[:id])
    @equipment.destroy
    flash[:notice] = "Successfully destroyed equipment."
    respond_to do |format|
      format.html { redirect_to equipments_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def quick_checkout
    @equipment = Equipment.find(params[:id])
    @reservation = @equipment.reservations.new(params[:reservation])
    @reservation.staff = true
    @reservation.person_id = current_user.person_id
    
    EquipmentReservation.transaction do
      if @reservation.save && @reservation.add!(@equipment, true) && @reservation.submit! && @reservation.save
        flash[:notice] = "Successfully reserved #{@equipment.title} for you."
        redirect_to :action => "show", :success_id => @reservation.id
      else
        flash[:error] = "Could not create your reservation."
        render :action => "show"
        raise ActiveRecord::Rollback
      end
    end
  end

  protected

  def add_equipment_breadcrumbs
    session[:breadcrumbs].add "Equipment", equipments_path
  end

end
