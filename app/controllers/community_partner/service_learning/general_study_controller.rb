class CommunityPartner::ServiceLearning::GeneralStudyController < CommunityPartner::ServiceLearningController
  before_filter :add_courses_breadcrumbs

  def students
  end
  
  def approve
    @general_study = @self_placement = ServiceLearningSelfPlacement.find(params[:id]) # @self_placement for self placement fields page.
    
    if @general_study.nil?
      flash[:error] = "Can not find the student's general study position."
      redirect_to :action => :students and return
    end    
    
    flash.now[:notice] = "This position has been approved already." if  @general_study.supervisor_approved?
    
    if request.put?
        @general_study.submitted = params[:service_learning_self_placement][:supervisor_approved]=="false" ? false : true
      if @general_study.save && @general_study.update_attributes(params[:service_learning_self_placement])
          if @general_study.supervisor_approved?
              flash[:notice] = "You successfully approved #{@general_study.position.name} for #{@self_placement.person.fullname} . Thank you."
          else
              template = EmailTemplate.find_by_name("general study request decline by site supervisor")
              TemplateMailer.deliver(template.create_email_to(@general_study, 
                                                              "http://#{CONSTANTS[:base_url_host]}/service_learning/general_study",
                                                              @general_study.person.email)
                                    ) if template            
              flash[:notice] = "You declined the general sutdy position request for #{@general_study.person.fullname}. A email with your feedback sent to the student."
          end
      end      
      redirect_to :action => :students
    end    
    session[:breadcrumbs].add "View General Study Positions"
  end
  
  protected
  
  def add_courses_breadcrumbs
    session[:breadcrumbs].add "General Study", community_partner_service_learning_general_study_path(@quarter, :action => 'students')
  end
  

end

