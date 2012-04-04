class Admin::Users::RolesController < Admin::UsersController
  
  before_filter :fetch_user
  
  # def index
  #   @roles = @user.roles.find :all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @roles }
  #   end
  # end
  # 
  # def show
  #   @role = @user.roles.find(params[:id])
  #   session[:breadcrumbs].add "#{@role.name}"
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @role }
  #   end
  # end
  # 
  # def new
  #   @role = @user.roles.new
  #   session[:breadcrumbs].add "New"
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @role }
  #   end
  # end
  # 
  # def edit
  #   @role = @user.roles.find(params[:id])
  #   session[:breadcrumbs].add "#{@role.name}", @role
  #   session[:breadcrumbs].add "Edit"
  # end

  def create
    @role = @user.roles.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = "Assigned #{@role.name} to #{@user.fullname}."
        format.html { redirect_to users_role_path(@user, @role) }
        format.xml  { render :xml => @role, :status => :created, :location => users_role_path(@user, @role) }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    @role = @user.roles.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = "Role was successfully updated."
        format.html { redirect_to users_role_path(@user, @role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @role = @user.roles.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(admin_roles_url) }
      format.xml  { head :ok }
      format.js
    end
  end
  
  protected
  
  def fetch_user
    @user = User.find params[:user_id]
  end
  
end