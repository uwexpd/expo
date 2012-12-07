class FacultyController < ApplicationController
  before_filter :initialize_breadcrumbs
  before_filter :fetch_person

  helper_method :get_breadcrumbs
  def get_breadcrumbs
    breadcrumbs
  end

  layout 'admin'

  def index
    redirect_to faculty_service_learning_home_path(Quarter.current_quarter)
  end

  def profile
  end

  protected
  
  def fetch_person
    @person = @current_user.person
  end
  
  def initialize_breadcrumbs
    session[:breadcrumbs] = BreadcrumbTrail.new
    session[:breadcrumbs].start
    session[:breadcrumbs].add "EXP-Online", "/expo", :class => 'home'
  end

end
