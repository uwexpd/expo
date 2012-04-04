# Users can be authorized on certain objects with respect to a specific role. For example, a user may be assigned the "Accountability Department Coordinator" role but only be authorized to modify accountibility records for a certain department. In this case, the role would be associated with one or more UserUnitRoleAuthorization objects -- one for each department the user is authorized to control. This is accomplished using a polymorphic association called +authorizable+ that can attach any object to an authorization.
class UserUnitRoleAuthorization < ActiveRecord::Base
  belongs_to :user_unit_role
  belongs_to :authorizable, :polymorphic => true
  
  validates_presence_of :user_unit_role_id, :authorizable_type, :authorizable_id
  
  delegate :user, :to => :user_unit_role
  delegate :login, :fullname, :firstname, :to => :user
end
