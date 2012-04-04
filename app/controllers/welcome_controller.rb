class WelcomeController < ApplicationController

  layout 'welcome'

  def index
    redirect_to admin_welcome_url if @current_user.admin?
    
    @person = @current_user.person
    @student = @person if @person.is_a?(Student)
    @service_learning_courses = @student ? @student.enrolled_service_learning_courses(Quarter.all) : @person.service_learning_courses
    
    @units = Unit.with_description.for_welcome_screen.find(:all, :order => "RAND()", :limit => 3 )
    
  end

end
