class Role < ActiveRecord::Base
  has_and_belongs_to_many :rights
  has_many :user_unit_roles
  has_many :users, :through => :user_unit_roles
  has_many :authorizations, :class_name => "UserUnitRoleAuthorization", :through => :user_unit_roles

  default_scope :order => 'name'

  def title
    name.titleize
  end

  def <=>(o)
    title <=> o.title rescue -1
  end

end
