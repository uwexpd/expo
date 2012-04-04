class MgeMigrate < ActiveRecord::Base

  self.abstract_class = true
  establish_connection :mgemigrate
  
end