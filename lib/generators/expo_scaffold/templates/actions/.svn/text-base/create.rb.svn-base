  def create
    @<%= singular_name %> = <%= collection_class_name %>.new(params[:<%= singular_name %>])

    respond_to do |format|
      if @<%= singular_name %>.save
        flash[:notice] = "Successfully created <%= singular_name.humanize.downcase %>."
        format.html { redirect_to <%= item_path %> }
        format.xml  { render :xml => @<%= singular_name %>, :status => :created, 
                             :location => <%= item_path %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end
