ActionController::Routing::Routes.draw do |map|

  # Admin Routes
  # ------------

  map.namespace :admin do |admin| 
    admin.welcome '/', :controller => 'base', :action => 'index'
	
	  admin.create_favorite_page '/favorite_pages/create', :controller => 'favorite_pages', :action => 'create'
	  admin.destroy_favorite_page '/favorite_pages/destroy', :controller => 'favorite_pages', :action => 'destroy'
	  admin.sort_favorite_pages '/favorite_pages/sort', :controller => 'favorite_pages', :action => 'sort'

    admin.accountability_authorizations '/accountability/authorizations/:action/:id', :controller => 'accountability/authorizations'
    admin.accountability_authorizations '/accountability/authorizations/:action', :controller => 'accountability/authorizations'
    admin.accountability_authorizations '/accountability/authorizations', :controller => 'accountability/authorizations'
    admin.accountability '/accountability', :controller => 'accountability'
	
  	admin.resources :pipeline_migrate, :member => { :create_migrate_file => :post } 
	
  	admin.resources :charts, :controller => 'charts', :collection => { 
  																		:offering_line_graph_applicants => :get , 
  																		:offering_pie_graph_standings => :get,
  																		:offering_bar_graph_statuses => :get,
  																		:offering_bar_graph_awarded => :get,
  																		:offering_hbar_sessions => :get,
  																		:appointment_graph => :get,
  																		:appointment_line_graph => :get }, :name_prefix => ''
  	admin.resources :discipline_categories, :member => { :remove_major => :delete, :add_major => :post } , :name_prefix => nil
  	admin.resources :major_extras, :member => { :edit_discipline_category => :post } , :name_prefix => nil
		
    admin.resources :equipments, :name_prefix => nil
    admin.resources :equipment_categories, :name_prefix => nil
    admin.resources :equipment_reservations, :name_prefix => nil, :collection => { :unit => :get, :all => :get,
                                                                              :todays_checkouts => :get,
                                                                              :todays_checkins => :get,
                                                                              :tomorrows_checkouts => :get,
                                                                              :tomorrows_checkins => :get,
                                                                              :late_returns => :get,
                                                                              :policies => :get,
                                                                              :current_checkout_viewing => :get },
                                                                  :member => { :approve => :post, 
                                                                              :checkin => [:get, :put], 
                                                                              :checkout => [:get, :put] }
    admin.resources :notes, :name_prefix => nil
    admin.resources :populations, :name_prefix => nil, 
                                  :as => 'queries',
                                  :collection => { :deleted => :get },
                                  :member => { :regenerate => :post, :refresh_dropdowns => :any, :undestroy => :delete,
                                                :objects => :any, :output => :get, :save_output_fields => :post,
                                                :clone => :put } do |populations|
      populations.resources :conditions, :controller => 'populations/conditions', 
                                          :member => { :refresh_dropdowns => :any }
    end
    admin.resources :population_groups, :name_prefix => nil, :member => { :objects => :any }
    admin.resources :quotes, :name_prefix => nil
    
    admin.front_desk 'front_desk', :controller => 'front_desk'
    admin.resources :appointments, :name_prefix => nil, :member => { :checkin => :post, :followup_to => :post }
  
    admin.resources :tickets, :collection => { :milestone => :get }
    admin.resources :help_texts, :collection => { :model => :get, :update_model => :post }
    admin.student_photo 'students/:reg_id/photo/:size.:format', :controller => 'students', :action => 'photo'
    admin.resources :students, {  :member => { :note => [:post, :put] }, 
                                  :collection => { :search => :any, :auto_complete_for_student_anything => :any } }
    admin.resources :people, { :member => { :note => [:post, :put] } }
    admin.session_history 'session_history/:id', 
                          :controller => 'users', :action => 'session_history', :name_prefix => '', :path_prefix => 'admin'
    admin.resources :users, { :name_prefix => '', :collection => {:history => :get, :search => :any, :admin => :get,
                                                                  :units_roles => :get, :roles_users => :get } } do |users|
      users.resources :roles, :controller => 'users/roles'
    end    
    admin.resources :pubcookie_users, { :controller => :users, :name_prefix => '' }
  
    admin.resources :units, :name_prefix => ''
     
    # Communications
    # admin.email_template 'email_template/:id', :controller => 'email_template', :action => 'show'
    # admin.template 'template', :controller => 'email_template', :action => 'index'
    # admin.template 'template/:id', :controller => 'email_template', :action => 'show'
    admin.namespace :communicate do |communicate|
      communicate.email 'write', :controller => 'email', :action => 'write', :name_prefix => 'write_'
      communicate.write_email 'write', :controller => 'email', :action => 'write'
      communicate.resources :email_queue
      communicate.resources :contact_history, :name_prefix => '', :collection => { :from_me => :get }, :member => { :requeue => :post }
      communicate.resources :templates
    end

    admin.resources :locations, :name_prefix => ''
    admin.resources :organizations, :collection => { :get_organization_contacts => :post } do |organizations|
      organizations.resources :contacts, :name_prefix => 'organization_', :controller => 'Organizations::Contacts', 
                                          :member => { :undestroy => :delete, :send_login_link => :get },
                                          :collection => { :move_organization_contact => :post }
    end

    admin.resources :committees do |committees|
      committees.resources :members, :controller => "Committees::Members", 
                                     :member => { :reviews => :get },
                                     :collection => { :change_status => :post } do |members|
        admin.committee_member_auto_complete 'committees/:committee_id/members/auto_complete_model_for_person_fullname', 
                                              :controller => "Committees::Members", :action => 'auto_complete_model_for_person_fullname'          
      end
      committees.resources :quarters, :controller => "Committees::Quarters"
      committees.resources :meetings, :controller => "Committees::Meetings"
      committees.resources :member_types, :controller => 'Committees::MemberTypes'
    end

    admin.resources :event_types, :controller => 'event_types', :name_prefix => ''

    admin.resources :events, :name_prefix => '', :collection => { :all => :get }, :member => { :attendees => :get, :sync_with_offering => [:get, :post], :clone => :put } do |events|  
      events.resources :times, :controller => 'events/times', :member => { :background_checks => :get } do |times|
        times.resources :sub_times, :controller => 'events/times/sub_times', 
                                    :collection => { :add_to_sub_time => :post, :mass_add_to_sub_time => :post }
        times.resources :invitees, :controller => 'events/times/invitees'
      end
      events.resources :staff_positions, :controller => 'events/staff_positions' do |staff_positions|
        staff_positions.resources :shifts, :controller => 'events/staff_positions/shifts' do |shifts|
          shifts.resources :staffs, :controller => 'events/staff_positions/shifts/staffs'
        end
      end
      events.resources :checkin, :controller => 'events/checkin', 
                                  :member => { :checkin => :any, :auto_complete => :any, :update_note => :post },
                                  :collection => { :find_student => :any, :status => :get, :mass => :get, :mass_checkin => :post,
                                                   :manual => :any }
      events.resources :nametags, :controller => 'events/nametags', 
                                  :collection => { :attendees => :any, :staff_position => :any, :other => :any }
    end

    # Online Applications
    admin.resources           :offerings, :name_prefix => '', :member => { :toggle_features => :put, :clone => :put } do |offerings|
      offerings.resources       :application_categories, :controller => 'offerings/application_categories'
  	  offerings.resources       :application_types, :controller => 'offerings/application_types'
  	  offerings.resources 		:invitation_codes,  :controller => 'offerings/invitation_codes', :collection => { :generate => :post }
  	  offerings.resources		:location_sections, :controller => 'offerings/location_sections'
  	  offerings.resources		:mentor_types, :controller => 'offerings/mentor_types'
  	  offerings.resources 		:mentor_questions, :controller => 'offerings/mentor_questions'
  	  offerings.resources 		:other_award_types, :controller => 'offerings/other_award_types'
      offerings.resources       :pages, :controller => 'offerings/pages', :collection => { :sort => :post } do |pages|
        pages.resources           :questions, :controller => 'offerings/pages/questions', 
                                              :collection => { :sort => :post },
                                              :member => { :preview => :any } do |questions|
          questions.resources       :validations, :controller => 'offerings/pages/questions/validations'
          questions.resources       :options, :controller => 'offerings/pages/questions/options'
        end
      end
      offerings.resources       :phases, :controller => 'offerings/phases' do |phases|
        phases.resources          :tasks, :controller => 'offerings/phases/tasks' do |tasks|
          tasks.resources           :extra_fields, :controller => 'offerings/phases/tasks/extra_fields'
        end
      end
      offerings.resources       :restrictions, :controller => 'offerings/restrictions' do |restrictions|
        restrictions.resources    :exemptions, :controller => 'offerings/restrictions/exemptions' 
      end
      offerings.resources       :statuses, :controller => 'offerings/statuses' do |statuses|
        statuses.resources       :emails, :controller => 'offerings/statuses/emails'
      end
      offerings.resources       :sessions, :controller => 'offerings/sessions', 
                                           :member => { :add_presenter => :put, :remove_presenter => :delete, :easels => :get, :sort_session_students => :post },
                                           :collection => { :disciplines => :get }
      offerings.resources       :dashboard_items, :controller => 'offerings/dashboard_items',
                                                  :member => { :disable => :post, :enable => :post }
      offerings.resources :review_criterions, :controller => 'offerings/review_criterions'
    end

    admin.namespace :apply, :name_prefix => 'admin_', :path_prefix => 'admin', :controller => 'admin/apply' do |apply|
      apply.resources :phases, :path_prefix => "admin/apply/:offering_id", :controller => 'phases',
                                  :member => { :switch_to => :post, :complete => :post } do |phases|
        phases.resources :tasks,  :controller => "phases/tasks",
                                  :collection => { :sort => :post, :mass_update => :post },
                                  :member => { :complete => :post, :uncomplete => :post, :refresh_task_completion_statuses => :post }
      end
    end

    # admin.apply_phase_task 'apply/:offering/phases/:phase_id/tasks/:id', :controller => 'apply/phases/tasks', :action => 'show'
    # admin.apply_phase 'apply/:offering/phases/:id', :controller => 'apply/phases', :action => 'show'
    admin.apply_home 'apply', :controller => 'apply', :action => 'all'
    admin.apply_create 'apply/create', :controller => 'apply', :action => 'create'
    admin.apply 'apply/approve', :controller => 'apply', :action => 'approve'
    admin.apply 'apply/finaid_approve', :controller => 'apply', :action => 'finaid_approve'
    admin.apply 'apply/disberse', :controller => 'apply', :action => 'disberse'
    admin.apply 'apply/disberse.:format', :controller => 'apply', :action => 'disberse'
    admin.apply_group_members 'apply/:offering/show/:application_id/group_members/:action/:id', :controller => 'apply/group_members'
    admin.resources :mentors, :path_prefix => "admin/apply/:offering/show/:application_id", 
                              :controller => 'apply/mentors',
                              :name_prefix => "admin_apply_"
    admin.apply_mentor_auto_complete 'apply/:offering/show/:application_id/mentors/auto_complete_model_for_person_fullname', 
                                          :controller => "apply/mentors", :action => 'auto_complete_model_for_person_fullname'
    admin.apply_applicant_auto_complete 'apply/:offering/auto_complete_for_person_fullname',
                                          :controller => 'apply', :action => 'auto_complete_model_for_person_fullname'
    admin.app   'apply/:offering/show/:id', :controller => 'apply', :action => 'show'
    admin.app_mini_details 'apply/:offering/mini_details/:id', :controller => 'apply', :action => 'mini_details'
    admin.apply 'apply/:offering/:action/:id.:format', :controller => 'apply'
    admin.apply 'apply/:offering/:action/:id', :controller => 'apply'
    admin.apply 'apply/:offering/:action.:format', :controller => 'apply'
    admin.apply 'apply/:offering/:action', :controller => 'apply'
    admin.apply_action 'apply/:offering/:action', :controller => 'apply'
    admin.apply 'apply/:offering', :controller => 'apply'
    admin.interview 'interview/:offering/:action/:id', :controller => 'interview'
    admin.interviewer 'interviewer/:offering/:action/:id', :controller => 'interviewer'

    # Pipeline 
    admin.resources :pipeline, :controller => 'pipeline', :collection => { :participants => :get,
                                                                           :student_questions => :get,
                                                                           :students => :get,
                                                                           :placements => :get,
                                                                           :create_position_attribute => :post,
                                                                           :update_position_attribute => :post,
                                                                           :remove_position_attribute => :delete,
                                                                           :group_background_check_clear => :post,
                                                                           :group_orientation_clear => :post,
                                                                           :group_toggle_active => :post } do |pipeline|
      pipeline.orientation_management 'orientation_management', :controller => "Pipeline",
                            :path_prefix => 'admin/pipeline/:quarter_abbrev', :action => 'orientation_management'
      pipeline.orientation_participants 'orientation_participants', :controller => "Pipeline",
                            :path_prefix => 'admin/pipeline/:quarter_abbrev', :action => 'orientation_participants'
      pipeline.resources :positions, :controller => "Pipeline::Positions", :path_prefix => 'admin/pipeline/:quarter_abbrev', 
                                           :collection => { :migrate_to_current_quarter => :post }
      
      pipeline.resources :organizations, :controller => "Pipeline::Organizations", :path_prefix => 'admin/pipeline/:quarter_abbrev',
                                           :member => { :add_note => :post, :new_position => :get,
                                                        :allow_position_edits => :post, :allow_evals => :post,
                                                        :students => :get },
                                           :collection => { :activate => :post, :deactivate => :delete, 
                                                            :partner_access => :get, :toggle_position_edits => :any,
                                                            :toggle_evals => :any, :remove_organization_quarter => :delete } do |organizations|
          organizations.resources   :positions, :controller => 'Pipeline::Organizations::Positions',
                                                                :collection => { :copy_from_previous => :any, 
                                                                                 :remote_add_subject => :post },
                                                                :member => { :update_course_slots => :post }
        end
    end
  
    # Service Learning    
    admin.service_learning_hide_change_log 'service_learning/hide_change_log', :controller => 'service_learning', :action => 'hide_change_log'
    admin.service_learning_pipeline_home 'service_learning/pipeline', :controller => 'pipeline', :action => 'index', :name_prefix => ''
    admin.service_learning_unit_home 'service_learning/:unit', :controller => 'service_learning', :action => 'index', :name_prefix => ''
    admin.service_learning_pipeline_quarter_home 'service_learning/pipeline/:quarter_abbrev', :controller => 'pipeline', :action => 'index', :name_prefix => ''
    admin.service_learning_home 'service_learning/:unit/:quarter_abbrev', :controller => 'service_learning', :action => 'index', :name_prefix => ''
    admin.service_learning_placements 'service_learning/:unit/:quarter_abbrev/placements', 
                                          :controller => 'service_learning', :action => 'placements', :name_prefix => ''
    admin.service_learning_mid_quarter 'service_learning/:unit/:quarter_abbrev/mid_quarter', 
                                          :controller => 'service_learning', :action => 'mid_quarter', :name_prefix => ''
    admin.service_learning_students 'service_learning/:unit/:quarter_abbrev/students', 
                                          :controller => 'service_learning', :action => 'students', :name_prefix => ''
    admin.service_learning_self_placements 'service_learning/:unit/:quarter_abbrev/self_placements',
                                          :controller => 'service_learning', :action => 'self_placements', :name_prefix => ''
    admin.service_learning_self_placement_approval 'service_learning/:unit/:quarter_abbrev/self_placements/:id',
                                          :controller => 'service_learning', :action => 'self_placement_approval', :name_prefix => ''
    admin.service_learning_self_placement_update 'service_learning/:unit/:quarter_abbrev/self_placement_update/:id',
                                          :controller => 'service_learning', :action => 'self_placement_update', :name_prefix => ''                                          
                
    admin.service_learning_pipeline_students 'service_learning/pipeline/:quarter_abbrev/students', 
                                              :controller => 'pipeline', :action => 'students', :name_prefix => ''
    admin.service_learning_pipeline_placements 'service_learning/pipeline/:quarter_abbrev/placements', 
                                                :controller => 'pipeline', :action => 'placements', :name_prefix => ''
    admin.service_learning_pipeline_manage_position_attributes 'service_learning/pipeline/:quarter_abbrev/manage_position_attributes', 
                                                :controller => 'pipeline', :action => 'manage_position_attributes', :name_prefix => ''
    
    admin.namespace :service_learning, :name_prefix => '' do |service_learning|
      service_learning.search ':unit/:quarter_abbrev/search', :controller => 'search'
      service_learning.auto_complete ':unit/:quarter_abbrev/auto_complete/:action', :controller => 'search'
            
      service_learning.resources    :positions,                 :path_prefix => 'admin/service_learning/:unit/:quarter_abbrev',
                                                                :collection => { :migrate_to_current_quarter => :post }
      service_learning.resources    :courses,                 { :path_prefix => 'admin/service_learning/:unit/:quarter_abbrev',
                                                                :collection => { :course_numbers => :any, 
                                                                                  :section_ids => :any,
                                                                                  :cross_listeds => :any,
                                                                                  :toggle_finalized => :post,
                                                                                  :toggle_open => :post,
                                                                                  :overview => :any,
                                                                                  :volunteers => :get,
                                                                                  :clone_positions_for_multiple_quarters => :post,
                                                                                  :clone_course => :post,
                                                                                  :change_quarter_option => :post },
                                                                :member => {  :students => :get,
                                                                              :add_note => :post,
                                                                              :finalize => :post,
                                                                              :open     => :post,
                                                                              :place    => :post,
                                                                              :unplace  => :delete,
                                                                              :add_paper_risk => :post,
                                                                              :positions_print => :get,
                                                                              :delete_organization_match => :delete,
                                                                              :overview => :any,
                                                                              :filters => :get,
                                                                              :toggle_use_filters => :post,
                                                                              :update_filters => :post,
                                                                              :get_pipeline_positions => :get,
                                                                              :place_pipeline_position => :post }
      } do |courses|
        # courses.evaluation          'evaluation/:id',           :controller => 'courses', :action => 'evaluation'
        courses.resources           :extra_enrollees      
        courses.resources           :instructors,               :controller => 'courses/instructors',
                                                                :collection => { :find_by_uw_netid => :any }
      end
    
      service_learning.student_evaluation ':unit/:quarter_abbrev/courses/:course_id/evaluation/:id', 
                                                                :controller => 'courses', :action => 'evaluation'
      service_learning.submit_student_evaluation ':unit/:quarter_abbrev/courses/:course_id/submit_evaluation/:id', 
                                                                :controller => 'courses', :action => 'submit_evaluation'

      service_learning.unsubmit_student_evaluation ':unit/:quarter_abbrev/courses/:course_id/unsubmit_evaluation/:id', 
                                                                :controller => 'courses', :action => 'unsubmit_evaluation'
                  
      service_learning.resources    :organizations,           { :path_prefix => 'admin/service_learning/:unit/:quarter_abbrev',
                                                                :member => { :add_note => :post, :new_position => :get,
                                                                             :allow_position_edits => :post, :allow_evals => :post,
                                                                             :delete_course_match => :delete,
                                                                             :students => :get, :remove_organization_quarter => :delete },
                                                                :collection => {  :activate => :post, :deactivate => :delete, 
                                                                                  :partner_access => :get, :toggle_position_edits => :any,
                                                                                  :toggle_evals => :any, :match_pipeline_placement => :post }
      } do |organizations|
          organizations.resources   :positions, :controller => 'Organizations::Positions',
                                                                :collection => { :copy_from_previous => :any }
        end
    
      # Lowest priority service_learning route: "home"  
      #service_learning.home ':quarter_abbrev', :path_prefix => 'admin/service_learning', :controller => 'service_learning'
    
    end
    
    admin.population_stats_query 'stats/query/population/:id', :controller => 'stats', :action => 'population'
    admin.stats_query 'stats/query', :controller => 'stats', :action => 'query'
    admin.stats_overview 'stats/overview', :controller => 'stats', :action => 'overview'
  
    admin.map 'uwsdb_reconnect', :controller => 'base', :action => 'uwsdb_reconnect'
    admin.ferpa_reminder 'ferpa_reminder', :controller => 'base', :action => 'ferpa_reminder'
    admin.vicarious_login 'vicarious_login', :controller => 'base', :action => 'vicarious_login'
    admin.remove_vicarious_login 'remove_vicarious_login', :controller => 'base', :action => 'remove_vicarious_login'
  end


  # Service Learning
  # admin.resources :service_learning do |service_learning|
  #   service_learning.resources :organizations, :path_prefix => ':quarter_id'
  #   service_learning.resources :positions, :path_prefix => ':quarter_id'
  #   service_learning.resources :courses, :path_prefix => ':quarter_id'
  # end


  # Public Routes
  # -------------

  # Users and Sessions
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'session', :action => 'new'
  map.logout 'logout', :controller => 'session', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'profile'
  map.namespace :users do |users|
    users.resources :email_addresses
  end
  map.reset_password 'session/reset/:user_id/:token', :controller => 'session', :action => 'reset_password'
  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.omniauth_callback "/auth/:provider/callback", :controller => 'session', :action => 'create'

  # Faculty
  map.faculty_profile 'faculty_profile', :controller => 'faculty', :action => 'profile'
  
  map.namespace :faculty, :controller => 'Faculty' do |faculty|
      faculty.service_learning_home 'service_learning', :controller => 'ServiceLearning'
      faculty.service_learning_home 'service_learning/:quarter_abbrev', :controller => 'ServiceLearning'
      faculty.service_learning 'service_learning/:quarter_abbrev/:action/:id', :controller => 'ServiceLearning'
  end

  # Community Partners
  map.community_partner_home 'community_partner_home', :controller => 'community_partner', :action => 'index'
  map.community_partner_wrong_person 'community_partner/wrong_person', :controller => 'community_partner', :action => 'wrong_person'
  map.community_partner_map 'community_partner_map', :controller => 'community_partner', :action => 'map'
  map.community_partner_profile 'community_partner_profile', :controller => 'community_partner', :action => 'profile'
  map.namespace :community_partner, :controller => 'CommunityPartner' do |community_partner|
    community_partner.service_learning_home 'service_learning/:quarter_abbrev', :controller => 'ServiceLearning'
    community_partner.namespace :service_learning,  :path_prefix => 'community_partner/service_learning/:quarter_abbrev',
                                                    :controller => 'ServiceLearning' do |service_learning|
      service_learning.resource 'organization',     :controller => 'Organization',
                                                    :path_prefix => 'community_partner/service_learning/:quarter_abbrev' do |organization|
        organization.resources 'contacts',          :member => { :send_login_link => :get }
      end
      service_learning.resources 'students',        :controller => 'Students',
                                                    :path_prefix => 'community_partner/service_learning/:quarter_abbrev',
                                                    :member => { :evaluate => :get, :submit_evaluation => :put }
      service_learning.resources 'courses',         :controller => 'Courses',
                                                    :path_prefix => 'community_partner/service_learning/:quarter_abbrev'
      service_learning.resources 'positions',       :controller => 'Positions',
                                                    :path_prefix => 'community_partner/service_learning/:quarter_abbrev',
                                                    :collection => { :copy_from_previous => :any }
    end
  end


  # Public Routes for Students
  # --------------------------

  # Service Learning
  map.service_learning 'service_learning/:action', :controller => 'service_learning', :quarter_abbrev => 'current'
  map.service_learning 'service_learning/:action/:id', :controller => 'service_learning', :quarter_abbrev => 'current'
  map.service_learning 'service_learning/current/:action', :controller => 'service_learning', :quarter_abbrev => 'current'
  map.service_learning 'service_learning/:quarter_abbrev/:action', :controller => 'service_learning'
  
  # Pipeline
  map.pipeline_base 'pipeline/', 
                :controller => 'pipeline', :action => "index"
  map.pipeline 'pipeline/find_bus_routes', 
                :controller => 'pipeline', :action => "find_bus_routes"
  map.pipeline_download_background_check 'pipeline/download_background_check', 
                :controller => 'pipeline', :action => "download_background_check"
  map.pipeline_which 'pipeline/which',
                :controller => 'pipeline', :action => "which"
  map.pipeline_stop_email 'pipeline/stop_email/:student_id/:token',
                :controller => 'pipeline', :action => "stop_email"
  map.pipeline_update_placement_quarter 'pipeline/update_placement_quarter/:id', 
                :controller => 'pipeline', :action => 'update_placement_quarter'
  map.pipeline_quarter 'pipeline/:quarter_abbrev/', 
                :controller => 'pipeline', :action => "index"
  map.pipeline 'pipeline/:quarter_abbrev/:course_abbrev', 
                :controller => 'pipeline', :action => "index"
  map.pipeline_favorites 'pipeline/:quarter_abbrev/:course_abbrev/favorites', 
                :controller => 'pipeline', :action => "favorites"  
  map.pipeline_search 'pipeline/:quarter_abbrev/:course_abbrev/search', 
                :controller => 'pipeline', :action => "search"
  map.pipeline_orientation_signup 'pipeline/:quarter_abbrev/:course_abbrev/orientation_signup', 
                :controller => 'pipeline', :action => "orientation_signup"
  map.pipeline_orientation_rsvp 'pipeline/:quarter_abbrev/:course_abbrev/orientation_rsvp', 
                :controller => 'pipeline', :action => "orientation_rsvp"
  map.pipeline_student_info 'pipeline/:quarter_abbrev/:course_abbrev/student_info', 
                :controller => 'pipeline', :action => "pipeline_student_info"
  map.pipeline_show 'pipeline/:quarter_abbrev/:course_abbrev/show/:id', 
                :controller => 'pipeline', :action => "show"
  map.pipeline_add_favorite 'pipeline/:quarter_abbrev/:course_abbrev/add_favorite/:id', 
                :controller => 'pipeline', :action => "add_favorite"
  map.pipeline_remove_favorite 'pipeline/:quarter_abbrev/:course_abbrev/remove_favorite/:id', 
                :controller => 'pipeline', :action => "remove_favorite"
  map.pipeline_confirm_position 'pipeline/:quarter_abbrev/:course_abbrev/confirm_position/:id', 
                :controller => 'pipeline', :action => "confirm_position"
  map.pipeline_remove_position_confirmation 'pipeline/:quarter_abbrev/:course_abbrev/remove_position_confirmation/:id', 
                :controller => 'pipeline', :action => "remove_position_confirmation"
  map.pipeline_checkin 'pipeline/:quarter_abbrev/:course_abbrev/checkin/:id/:token', 
                :controller => 'pipeline', :action => 'checkin'
  map.pipeline_email_remove_confirmation 'pipeline/:quarter_abbrev/:course_abbrev/email_remove_confirmation/:id', 
                :controller => 'pipeline', :action => 'email_remove_confirmation'                                

  map.resources :tutoring_log,
                :name_prefix => "pipeline_",
                :path_prefix => 'pipeline/:quarter_abbrev/:course_abbrev/:placement',
                :controller => 'pipeline/tutoring_log',
                :collection => { :submit => :put }
  map.pipeline_tutoring 'pipeline/:quarter_abbrev/:course_abbrev/:placement', :controller => 'pipeline/tutoring_log', :action => 'index'
        
  # Online Applications
  map.apply_proceedings_favorites 'apply/:offering/proceedings/favorites/:action/:id.:format', :controller => 'apply/proceedings/favorites'
  map.apply_proceedings_favorites_home 'apply/:offering/proceedings/favorites.:format', :controller => 'apply/proceedings/favorites'
  map.apply_proceedings    'apply/:offering/proceedings/:action/:id.:format', :controller => 'apply/proceedings'
  map.apply_proceedings    'apply/:offering/proceedings/:action', :controller => 'apply/proceedings'
  map.apply_lookup    'apply/:offering/lookup/:action', :controller => 'apply/lookup'
  map.apply_confirmation_guests 'apply/:offering/confirmation/guests/:action/:id', :controller => 'apply/confirmation/guests'
  map.apply_confirmation 'apply/:offering/confirmation/:action', :controller => 'apply/confirmation'
  map.apply_group_member_validation 'apply/:offering/validate/:group_member_id/:token', :action => 'group_member_validation', :controller => 'apply'
  map.apply_abstract  'apply/:offering/abstract.:format', :action => 'abstract', :controller => 'apply'
  map.apply_text      'apply/:offering/application_text/:title.:format', :action => 'application_text', :controller => 'apply'
  map.apply_text      'apply/:offering/application_text/:title', :action => 'application_text', :controller => 'apply'
  map.apply_help      'apply/:offering/help/:id', :action => 'help', :controller => 'apply'
  map.apply_which     'apply/:offering/which', :controller => 'apply', :action => 'which'
  map.apply           'apply/:offering/:action/:page', :action => 'page', :controller => 'apply', :requirements => { :offering => /\d+/ }
  map.apply           'apply/:offering/:action', :controller => 'apply', :requirements => { :offering => /\d+/ }
  map.apply_list      'apply/:offering/', :controller => 'apply', :action => 'list'
  map.apply           'apply/:offering/', :controller => 'apply', :requirements => { :offering => /\d+/ }
  map.apply_list      'apply/', :controller => 'apply', :action => 'list'
  map.mentor_map      'mentor/map/:mentor_id/:token', :controller => 'mentor', :action => 'map'
  map.mentor_offering_map 'mentor/offering/:offering_id/map/:mentor_id/:token', :controller => 'mentor', :action => 'map'
  map.mentor_offering 'mentor/offering/:offering_id/:action/:id', :controller => 'mentor'
  map.mentor          'mentor/:action/:id', :controller => 'mentor'
  map.review_committee 'reviewer/:offering/committee/:action/:id', :controller => 'reviewer/committee'
  map.reviewer        'reviewer/:offering/:action/:id', :controller => 'reviewer'
  map.interview_committee 'interviewer/:offering/committee/:action/:id', :controller => 'interviewer/committee'
  map.interviewer     'interviewer/:offering/:action/:id', :controller => 'interviewer'
  map.moderator       'moderator/:offering/:action/:id', :controller => 'moderator'

  # Equipment Reservations
  map.reserve       'equipment', :controller => 'equipment_reservation'

  # RSVP for events
  map.rsvp_event      'rsvp/event/:id', :controller => 'rsvp', :action => 'event'
  map.rsvp_attend     'rsvp/attend/:id', :controller => 'rsvp', :action => 'attend'
  map.rsvp_unattend   'rsvp/unattend/:id', :controller => 'rsvp', :action => 'unattend'
  map.rsvp            'rsvp', :controller => 'rsvp'

  # Volunteer for events
  map.volunteer_event 'volunteer/event/:id', :controller => 'volunteer', :action => 'event'
  map.volunteer_signup 'volunteer/signup/:id', :controller => 'volunteer', :action => 'signup'
  map.volunteer_unsignup 'volunteer/unsignup/:id', :controller => 'volunteer', :action => 'unsignup'
  map.volunteer       'volunteer', :controller => 'volunteer'

  # Committee Members
  map.committee_member_map 'committee_member/map/:committee_member_id/:token', :controller => 'committee_member', :action => 'map'
#  map.committee_member_map 'committee_member_map', :controller => 'committee_mmeber', :action => 'map'
  map.committee_member_profile 'committee_member_profile', :controller => 'committee_member', :action => 'profile'
  map.committee_member 'committee_member/:action', :controller => 'committee_member'

  # Locations
  map.location_summary 'location_summary/:id', :controller => 'application', :action => 'location_summary'
  map.location_fields 'location_fields/:id', :controller => 'application', :action => 'location_fields'
  
  # Public page
  map.public_page 'public/offering/:id', :controller => 'public' ,:action => 'scholarslist'

  # Accountability
  map.resources :authorizations, 
                :name_prefix => "accountability_reporting_", 
                :path_prefix => '/accountability/reporting/:year',
                :controller => 'accountability/reporting/authorizations'
  map.resources :courses, 
                :name_prefix => "accountability_reporting_", 
                :path_prefix => '/accountability/reporting/:year',
                :controller => 'accountability/reporting/courses',
                :collection => { :mass_add => :post, :mass_create => :put }
  map.resources :individuals, 
                :name_prefix => "accountability_reporting_", 
                :path_prefix => '/accountability/reporting/:year',
                :controller => 'accountability/reporting/individuals',
                :collection => { :upload => :get, :upload_map => :put, 
                                :upload_create => :put, :mass_add => :any, :student_search => :post,
                                :individual_reporting_template => :get }
  map.accountability_reporting 'accountability/reporting/:year/:action', :controller => 'accountability/reporting'
  map.accountability_reporting 'accountability/reporting/:year', :controller => 'accountability/reporting', :action => 'index'
  map.accountability_year 'accountability/year/:id', :controller => 'accountability', :action => 'year'
  map.accountability 'accountability', :controller => 'accountability', :action => 'index'
  
  # Default Route and Welcome
  # -------------------------

  # Default Route
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
  # Welcome Page
  map.connect '', :controller => "welcome"
  map.root :controller => 'welcome'
  
end
