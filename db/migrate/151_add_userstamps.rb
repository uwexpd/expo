class AddUserstamps < ActiveRecord::Migration
  def self.up
    add_column :activities, :creator_id, :integer                                       
    add_column :activities, :updater_id, :integer                                       
    add_column :activities, :deleter_id, :integer                                       
    add_column :application_answers, :creator_id, :integer                              
    add_column :application_answers, :updater_id, :integer                              
    add_column :application_answers, :deleter_id, :integer                              
    add_column :application_awards, :creator_id, :integer                               
    add_column :application_awards, :updater_id, :integer                               
    add_column :application_awards, :deleter_id, :integer                               
    add_column :application_files, :creator_id, :integer                                
    add_column :application_files, :updater_id, :integer                                
    add_column :application_files, :deleter_id, :integer                                
    add_column :application_for_offerings, :creator_id, :integer                        
    add_column :application_for_offerings, :updater_id, :integer                        
    add_column :application_for_offerings, :deleter_id, :integer                        
    add_column :application_interview_decision_types, :creator_id, :integer             
    add_column :application_interview_decision_types, :updater_id, :integer             
    add_column :application_interview_decision_types, :deleter_id, :integer             
    add_column :application_interviewers, :creator_id, :integer                         
    add_column :application_interviewers, :updater_id, :integer                         
    add_column :application_interviewers, :deleter_id, :integer                         
    add_column :application_mentors, :creator_id, :integer                              
    add_column :application_mentors, :updater_id, :integer                              
    add_column :application_mentors, :deleter_id, :integer                              
    add_column :application_other_awards, :creator_id, :integer                         
    add_column :application_other_awards, :updater_id, :integer                         
    add_column :application_other_awards, :deleter_id, :integer                         
    add_column :application_pages, :creator_id, :integer                                
    add_column :application_pages, :updater_id, :integer                                
    add_column :application_pages, :deleter_id, :integer                                
    add_column :application_review_decision_types, :creator_id, :integer                
    add_column :application_review_decision_types, :updater_id, :integer                
    add_column :application_review_decision_types, :deleter_id, :integer                
    add_column :application_reviewers, :creator_id, :integer                            
    add_column :application_reviewers, :updater_id, :integer                            
    add_column :application_reviewers, :deleter_id, :integer                            
    add_column :application_status_types, :creator_id, :integer                         
    add_column :application_status_types, :updater_id, :integer                         
    add_column :application_status_types, :deleter_id, :integer                         
    add_column :application_statuses, :creator_id, :integer                             
    add_column :application_statuses, :updater_id, :integer                             
    add_column :application_statuses, :deleter_id, :integer                             
    add_column :contact_histories, :creator_id, :integer                                
    add_column :contact_histories, :updater_id, :integer                                
    add_column :contact_histories, :deleter_id, :integer                                
    add_column :disbersement_types, :creator_id, :integer                               
    add_column :disbersement_types, :updater_id, :integer                               
    add_column :disbersement_types, :deleter_id, :integer                               
    add_column :email_queues, :creator_id, :integer                                     
    add_column :email_queues, :updater_id, :integer                                     
    add_column :email_queues, :deleter_id, :integer                                     
    add_column :email_templates, :creator_id, :integer                                  
    add_column :email_templates, :updater_id, :integer                                  
    add_column :email_templates, :deleter_id, :integer                                  
    add_column :interview_availabilities, :creator_id, :integer                         
    add_column :interview_availabilities, :updater_id, :integer                         
    add_column :interview_availabilities, :deleter_id, :integer                         
    add_column :notes, :creator_id, :integer                                            
    add_column :notes, :updater_id, :integer                                            
    add_column :notes, :deleter_id, :integer                                            
    add_column :offering_admin_phases, :creator_id, :integer                            
    add_column :offering_admin_phases, :updater_id, :integer                            
    add_column :offering_admin_phases, :deleter_id, :integer                            
    add_column :offering_interview_applicants, :creator_id, :integer                    
    add_column :offering_interview_applicants, :updater_id, :integer                    
    add_column :offering_interview_applicants, :deleter_id, :integer                    
    add_column :offering_interview_interviewers, :creator_id, :integer                  
    add_column :offering_interview_interviewers, :updater_id, :integer                  
    add_column :offering_interview_interviewers, :deleter_id, :integer                  
    add_column :offering_interview_timeblocks, :creator_id, :integer                    
    add_column :offering_interview_timeblocks, :updater_id, :integer                    
    add_column :offering_interview_timeblocks, :deleter_id, :integer                    
    add_column :offering_interviewer_conflict_of_interests, :creator_id, :integer       
    add_column :offering_interviewer_conflict_of_interests, :updater_id, :integer       
    add_column :offering_interviewer_conflict_of_interests, :deleter_id, :integer       
    add_column :offering_interviewers, :creator_id, :integer                            
    add_column :offering_interviewers, :updater_id, :integer                            
    add_column :offering_interviewers, :deleter_id, :integer                            
    add_column :offering_interviews, :creator_id, :integer                              
    add_column :offering_interviews, :updater_id, :integer                              
    add_column :offering_interviews, :deleter_id, :integer                              
    add_column :offering_page_types, :creator_id, :integer                              
    add_column :offering_page_types, :updater_id, :integer                              
    add_column :offering_page_types, :deleter_id, :integer                              
    add_column :offering_pages, :creator_id, :integer                                   
    add_column :offering_pages, :updater_id, :integer                                   
    add_column :offering_pages, :deleter_id, :integer                                   
    add_column :offering_question_options, :creator_id, :integer                        
    add_column :offering_question_options, :updater_id, :integer                        
    add_column :offering_question_options, :deleter_id, :integer                        
    add_column :offering_question_validations, :creator_id, :integer                    
    add_column :offering_question_validations, :updater_id, :integer                    
    add_column :offering_question_validations, :deleter_id, :integer                    
    add_column :offering_questions, :creator_id, :integer                               
    add_column :offering_questions, :updater_id, :integer                               
    add_column :offering_questions, :deleter_id, :integer                               
    add_column :offering_restriction_exemptions, :creator_id, :integer                  
    add_column :offering_restriction_exemptions, :updater_id, :integer                  
    add_column :offering_restriction_exemptions, :deleter_id, :integer                  
    add_column :offering_restrictions, :creator_id, :integer                            
    add_column :offering_restrictions, :updater_id, :integer                            
    add_column :offering_restrictions, :deleter_id, :integer                            
    add_column :offering_reviewers, :creator_id, :integer                               
    add_column :offering_reviewers, :updater_id, :integer                               
    add_column :offering_reviewers, :deleter_id, :integer                               
    add_column :offering_status_emails, :creator_id, :integer                           
    add_column :offering_status_emails, :updater_id, :integer                           
    add_column :offering_status_emails, :deleter_id, :integer                           
    add_column :offering_statuses, :creator_id, :integer                                
    add_column :offering_statuses, :updater_id, :integer                                
    add_column :offering_statuses, :deleter_id, :integer                                
    add_column :offerings, :creator_id, :integer                                        
    add_column :offerings, :updater_id, :integer                                        
    add_column :offerings, :deleter_id, :integer                                        
    add_column :people, :creator_id, :integer                                           
    add_column :people, :updater_id, :integer                                           
    add_column :people, :deleter_id, :integer                                           
    add_column :quarter_codes, :creator_id, :integer                                    
    add_column :quarter_codes, :updater_id, :integer                                    
    add_column :quarter_codes, :deleter_id, :integer                                    
    add_column :quarters, :creator_id, :integer                                         
    add_column :quarters, :updater_id, :integer                                         
    add_column :quarters, :deleter_id, :integer                                         
    add_column :rights, :creator_id, :integer                                           
    add_column :rights, :updater_id, :integer                                           
    add_column :rights, :deleter_id, :integer                                           
    add_column :rights_roles, :creator_id, :integer                                     
    add_column :rights_roles, :updater_id, :integer                                     
    add_column :rights_roles, :deleter_id, :integer                                     
    add_column :roles, :creator_id, :integer                                            
    add_column :roles, :updater_id, :integer                                            
    add_column :roles, :deleter_id, :integer                                            
    add_column :units, :creator_id, :integer                                            
    add_column :units, :updater_id, :integer                                            
    add_column :units, :deleter_id, :integer                                            
    add_column :user_unit_roles, :creator_id, :integer                                  
    add_column :user_unit_roles, :updater_id, :integer                                  
    add_column :user_unit_roles, :deleter_id, :integer                                  
    add_column :users, :creator_id, :integer                                            
    add_column :users, :updater_id, :integer                                            
    add_column :users, :deleter_id, :integer                                            
    add_column :users_user_unit_roles, :creator_id, :integer                            
    add_column :users_user_unit_roles, :updater_id, :integer                            
    add_column :users_user_unit_roles, :deleter_id, :integer                            
  end

  def self.down
    remove_column :activities, :creator_id
    remove_column :activities, :updater_id
    remove_column :activities, :deleter_id
    remove_column :application_answers, :creator_id
    remove_column :application_answers, :updater_id
    remove_column :application_answers, :deleter_id
    remove_column :application_awards, :creator_id
    remove_column :application_awards, :updater_id
    remove_column :application_awards, :deleter_id
    remove_column :application_files, :creator_id
    remove_column :application_files, :updater_id
    remove_column :application_files, :deleter_id
    remove_column :application_for_offerings, :creator_id
    remove_column :application_for_offerings, :updater_id
    remove_column :application_for_offerings, :deleter_id
    remove_column :application_interview_decision_types, :creator_id
    remove_column :application_interview_decision_types, :updater_id
    remove_column :application_interview_decision_types, :deleter_id
    remove_column :application_interviewers, :creator_id
    remove_column :application_interviewers, :updater_id
    remove_column :application_interviewers, :deleter_id
    remove_column :application_mentors, :creator_id
    remove_column :application_mentors, :updater_id
    remove_column :application_mentors, :deleter_id
    remove_column :application_other_awards, :creator_id
    remove_column :application_other_awards, :updater_id
    remove_column :application_other_awards, :deleter_id
    remove_column :application_pages, :creator_id
    remove_column :application_pages, :updater_id
    remove_column :application_pages, :deleter_id
    remove_column :application_review_decision_types, :creator_id
    remove_column :application_review_decision_types, :updater_id
    remove_column :application_review_decision_types, :deleter_id
    remove_column :application_reviewers, :creator_id
    remove_column :application_reviewers, :updater_id
    remove_column :application_reviewers, :deleter_id
    remove_column :application_status_types, :creator_id
    remove_column :application_status_types, :updater_id
    remove_column :application_status_types, :deleter_id
    remove_column :application_statuses, :creator_id
    remove_column :application_statuses, :updater_id
    remove_column :application_statuses, :deleter_id
    remove_column :contact_histories, :creator_id
    remove_column :contact_histories, :updater_id
    remove_column :contact_histories, :deleter_id
    remove_column :disbersement_types, :creator_id
    remove_column :disbersement_types, :updater_id
    remove_column :disbersement_types, :deleter_id
    remove_column :email_queues, :creator_id
    remove_column :email_queues, :updater_id
    remove_column :email_queues, :deleter_id
    remove_column :email_templates, :creator_id
    remove_column :email_templates, :updater_id
    remove_column :email_templates, :deleter_id
    remove_column :interview_availabilities, :creator_id
    remove_column :interview_availabilities, :updater_id
    remove_column :interview_availabilities, :deleter_id
    remove_column :notes, :creator_id
    remove_column :notes, :updater_id
    remove_column :notes, :deleter_id
    remove_column :offering_admin_phases, :creator_id
    remove_column :offering_admin_phases, :updater_id
    remove_column :offering_admin_phases, :deleter_id
    remove_column :offering_interview_applicants, :creator_id
    remove_column :offering_interview_applicants, :updater_id
    remove_column :offering_interview_applicants, :deleter_id
    remove_column :offering_interview_interviewers, :creator_id
    remove_column :offering_interview_interviewers, :updater_id
    remove_column :offering_interview_interviewers, :deleter_id
    remove_column :offering_interview_timeblocks, :creator_id
    remove_column :offering_interview_timeblocks, :updater_id
    remove_column :offering_interview_timeblocks, :deleter_id
    remove_column :offering_interviewer_conflict_of_interests, :creator_id
    remove_column :offering_interviewer_conflict_of_interests, :updater_id
    remove_column :offering_interviewer_conflict_of_interests, :deleter_id
    remove_column :offering_interviewers, :creator_id
    remove_column :offering_interviewers, :updater_id
    remove_column :offering_interviewers, :deleter_id
    remove_column :offering_interviews, :creator_id
    remove_column :offering_interviews, :updater_id
    remove_column :offering_interviews, :deleter_id
    remove_column :offering_page_types, :creator_id
    remove_column :offering_page_types, :updater_id
    remove_column :offering_page_types, :deleter_id
    remove_column :offering_pages, :creator_id
    remove_column :offering_pages, :updater_id
    remove_column :offering_pages, :deleter_id
    remove_column :offering_question_options, :creator_id
    remove_column :offering_question_options, :updater_id
    remove_column :offering_question_options, :deleter_id
    remove_column :offering_question_validations, :creator_id
    remove_column :offering_question_validations, :updater_id
    remove_column :offering_question_validations, :deleter_id
    remove_column :offering_questions, :creator_id
    remove_column :offering_questions, :updater_id
    remove_column :offering_questions, :deleter_id
    remove_column :offering_restriction_exemptions, :creator_id
    remove_column :offering_restriction_exemptions, :updater_id
    remove_column :offering_restriction_exemptions, :deleter_id
    remove_column :offering_restrictions, :creator_id
    remove_column :offering_restrictions, :updater_id
    remove_column :offering_restrictions, :deleter_id
    remove_column :offering_reviewers, :creator_id
    remove_column :offering_reviewers, :updater_id
    remove_column :offering_reviewers, :deleter_id
    remove_column :offering_status_emails, :creator_id
    remove_column :offering_status_emails, :updater_id
    remove_column :offering_status_emails, :deleter_id
    remove_column :offering_statuses, :creator_id
    remove_column :offering_statuses, :updater_id
    remove_column :offering_statuses, :deleter_id
    remove_column :offerings, :creator_id
    remove_column :offerings, :updater_id
    remove_column :offerings, :deleter_id
    remove_column :people, :creator_id
    remove_column :people, :updater_id
    remove_column :people, :deleter_id
    remove_column :quarter_codes, :creator_id
    remove_column :quarter_codes, :updater_id
    remove_column :quarter_codes, :deleter_id
    remove_column :quarters, :creator_id
    remove_column :quarters, :updater_id
    remove_column :quarters, :deleter_id
    remove_column :rights, :creator_id
    remove_column :rights, :updater_id
    remove_column :rights, :deleter_id
    remove_column :rights_roles, :creator_id
    remove_column :rights_roles, :updater_id
    remove_column :rights_roles, :deleter_id
    remove_column :roles, :creator_id
    remove_column :roles, :updater_id
    remove_column :roles, :deleter_id
    remove_column :units, :creator_id
    remove_column :units, :updater_id
    remove_column :units, :deleter_id
    remove_column :user_unit_roles, :creator_id
    remove_column :user_unit_roles, :updater_id
    remove_column :user_unit_roles, :deleter_id
    remove_column :users, :creator_id
    remove_column :users, :updater_id
    remove_column :users, :deleter_id
    remove_column :users_user_unit_roles, :creator_id
    remove_column :users_user_unit_roles, :updater_id
    remove_column :users_user_unit_roles, :deleter_id
  end
end