class AddIndexToServiceLearningPositionTime < ActiveRecord::Migration
  def self.up
    add_index :service_learning_position_times, :service_learning_position_id, :name => "index_times_on_position_id"
    add_index :application_awards, [:application_for_offering_id], :name => "index_awards_on_app_id"
    add_index :application_for_offerings, [:offering_id], :name => "index_applications_on_offering_id"
    add_index :application_mentors, [:application_for_offering_id], :name => "index_mentors_on_app_id"
    add_index :application_mentors, [:person_id], :name => "index_mentors_on_person_id"
    add_index :application_pages, [:application_for_offering_id], :name => "index_pages_on_app_id"
    add_index :application_reviewers, [:application_for_offering_id], :name => "index_reviewers_on_app_id"
    add_index :application_reviewers, [:offering_reviewer_id], :name => "index_reviewers_on_offering_reviewer_id"
    add_index :application_reviewers, [:committee_member_id], :name => "index_reviewers_on_committee_member_id"
    add_index :application_statuses, [:application_for_offering_id], :name => "index_statuses_on_app_id"
    add_index :application_text_versions, [:application_text_id], :name => "index_text_versions_on_text_id"
    add_index :changes, [:change_loggable_id, :change_loggable_type], :name => "index_changes_on_changable"
    add_index :evaluation_responses, [:evaluation_id], :name => "index_evaluation_responses_on_evaluation_id"
    add_index :evaluations, [:evaluatable_id, :evaluatable_type], :name => "index_evaluations_on_evaluatable"
    add_index :event_invitees, [:invitable_id, :invitable_type], :name => "index_event_invitees_on_invitable"
    add_index :event_invitees, [:event_time_id], :name => "index_event_invitees_on_event_time_id"
    add_index :interview_availabilities, [:application_for_offering_id], :name => "index_availabilities_on_app_id"
    add_index :organization_quarter_statuses, [:organization_quarter_id], :name => "index_quarter_status_on_org_quarter_id"
    add_index :tokens, [:tokenable_id, :tokenable_type], :name => "index_tokens_on_tokenable"
    add_index :tokens, :token
    add_index :users, :person_id
  end

  def self.down
    remove_index :users, :person_id
    remove_index :tokens, :column => :token
    remove_index :tokens, :name => :index_tokens_on_tokenable
    remove_index :organization_quarter_statuses, :name => :index_quarter_status_on_org_quarter_id
    remove_index :interview_availabilities, :name => :index_availabilities_on_app_id
    remove_index :event_invitees, :name => :index_event_invitees_on_event_time_id
    remove_index :event_invitees, :name => :index_event_invitees_on_invitable
    remove_index :evaluations, :name => :index_evaluations_on_evaluatable
    remove_index :evaluation_responses, :name => :index_evaluation_responses_on_evaluation_id
    remove_index :changes, :name => :index_changes_on_changable
    remove_index :application_text_versions, :name => :index_text_versions_on_text_id
    remove_index :application_statuses, :name => :index_statuses_on_app_id
    remove_index :application_reviewers, :name => :index_reviewers_on_committee_member_id
    remove_index :application_reviewers, :name => :index_reviewers_on_offering_reviewer_id
    remove_index :application_reviewers, :name => :index_reviewers_on_app_id
    remove_index :application_pages, :name => :index_pages_on_app_id
    remove_index :application_mentors, :name => :index_mentors_on_person_id
    remove_index :application_mentors, :name => :index_mentors_on_app_id
    remove_index :application_for_offerings, :name => :index_applications_on_offering_id
    remove_index :application_awards, :name => :index_awards_on_app_id
    remove_index :service_learning_position_times, :name => :index_times_on_position_id
  end
end
