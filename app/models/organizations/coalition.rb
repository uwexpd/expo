# An Organization can belong to a Coalition, which is a related group of Organizations. This is _different_ from a "parent organization" relationship. A parent organization is one that is holds administrative control of some sort over the child organization. Typically, a Coalition has no official control over its member organizations. These two structures exist in EXPo to allow for an Organization to be part of one or more Coalitions and also be managed by a parent Organization.
class Coalition < ActiveRecord::Base
  stampable
  has_and_belongs_to_many :organizations
  
end
