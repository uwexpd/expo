  def index
    @<%= plural_name %> = <%= collection_class_name %>.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= plural_name %> }
    end
  end
  