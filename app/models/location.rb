# Models a location object, representing a location in reality. Each location stores information such as address and directions, and also tracks a site supervisor (if applicable).
class Location < ActiveRecord::Base
  stampable
  has_many :service_learning_positions
  has_many :service_learning_orientations
  belongs_to :organization
  
  def <=>(o)
    title <=> o.title rescue -1
  end
  
  # Returns an array of Geocoded lat/long for use with Google Maps
  def to_latlon
    address = address_line_1, address_line_2, address_city, address_state, address_zip
    results = Geocoding::get(address.join(", "))
    results[0].latlon if results.status == Geocoding::GEO_SUCCESS
  end
  
end
