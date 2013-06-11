class Dilps::Collection < Dilps::Base
  self.primary_key = 'id'
  self.table_name = 'collections'
  self.inheritance_column = :nil
end
