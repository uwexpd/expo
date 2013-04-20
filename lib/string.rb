class String
  
  #is_numeric? "545"  #true,  is_numeric? "2aa"  #false
  def is_numeric?
     self.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
  
end