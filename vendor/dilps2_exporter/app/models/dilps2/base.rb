class Dilps2::Base < ActiveRecord::Base
  self.abstract_class = true
  
  establish_connection 'dilps2_local'
  self.inheritance_column = 'not_used'

end
