class SympMigrate < ActiveRecord::Base

  self.abstract_class = true
  establish_connection :symposium2008
  
end