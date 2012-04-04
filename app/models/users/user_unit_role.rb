class UserUnitRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :unit

  has_many :authorizations, :class_name => "UserUnitRoleAuthorization", :dependent => :destroy

  delegate :person, :email, :fullname, :login, :to => :user

  validates_presence_of :user_id
  validates_uniqueness_of :role_id, :message => "has already been assigned to that user for that unit", :scope => [:unit_id, :user_id]
  validate :unit_or_role_must_be_defined
  
  # Unit can be nil and Role can be nil, but not both.
  def unit_or_role_must_be_defined
    if unit_id.blank? && role_id.blank?
      errors.add_to_base "Either the unit or the role must be defined; you can't leave both blank."
    end
  end

  # Returns the titleized name of the role if it is set, or returns "User".
  def name
    role.nil? ? "User" : role.name.titleize
  end

  # Returns the symbolized name of the role.
  def to_sym
    role.nil? ? :user : role.name.downcase.to_sym
  end

  # Returns the description of the role if it is set, or returns nil.
  def description
    role.nil? ? nil : role.description
  end

  def authorize_for(authorizable)
    return false unless authorizable
    if exists = authorizations.find_by_authorizable_type_and_authorizable_id(authorizable.class.to_s, authorizable.id)
      return exists
    else
      authorizations.create(:authorizable => authorizable)
    end
  end

  def <=>(o)
    unit <=> o.unit rescue -1 
  end

end
