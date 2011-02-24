class Dilps2::Collection < Dilps2::Base
  set_table_name 'd2_collection'
  set_primary_key 'collectionid'

  has_many :items, :class_name => "Dilps2::Item",
                   :foreign_key => "collectionid"
  

  has_many :groups, :class_name => "Dilps2::Group",
                    :foreign_key => "collectionid"


end
