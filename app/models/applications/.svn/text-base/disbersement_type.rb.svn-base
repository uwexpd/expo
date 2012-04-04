# Each ApplicationAward is assigned a disbersement type, which is usually one of +cash+ or +tuition+.  This is used by the financial aid office to distinguish between different student accounts depending on financial aid eligibility, and will be used when disbersing awards.
class DisbersementType < ActiveRecord::Base
  stampable
  has_many :application_awards
  
  PLACEHOLDER_CODES = %w( name )
  
end
