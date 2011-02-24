class Dilps2::Item < Dilps2::Base
  set_table_name 'd2_item'
  set_primary_key 'imageid'

  has_many :resources, :class_name => "Dilps2::Resource",
                       :foreign_key => "itemid",
                       :conditions => {:collectionid => '#{collectionid}'}

  has_one :main_resource, :class_name => "Dilps2::Resource",
                          :foreign_key => "itemid",
                          :conditions => {:collectionid => '#{collectionid}', :main => true}

  belongs_to :item_rev, :class_name => "Dilps2::ItemRev", :foreign_key => "item_revid"
  belongs_to :collection, :class_name => "Dilps2::Collection", :foreign_key => "collectionid"


  default_scope :conditions => {:deleted => 0} #, :include => [:item_rev, :main_resource]
  
	#old# named_scope :saeulenprojekt, :conditions => {:collectionid => 11}



  def to_json_with_custom(options = {})
    options[:except] = [:item_revid, :imageid, :deleted, :creation_date, :modification_date] unless options[:except]
    options[:include] = {:item_rev => {:except => [:id, :itemid, :modify_date, :name1sounds, :name2sounds, :locationsounds, :locationid],
                                       :include => {:item_ext_data => {:except => [:id, :item_revid, :item_ext_data_id] }} },
                         :main_resource => {:except => [:id, :itemid, :resource_revid, :main, :deleted, :creation_date, :modification_date],
                                            :include => {:resource_rev => {:except => [:id, :resource_id, :resource_base_id, :creation_date, :thumb, :type, :mimetype, :filename, :fileinfo, :urn],
                                                                           :include => {:urn_file => {:except => [:urnid]}} } }
                                                                           } } unless options[:include]
    to_json_without_custom(options)
  end
  alias_method_chain :to_json, :custom


end
