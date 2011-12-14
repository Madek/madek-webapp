# -*- encoding : utf-8 -*-
class Media::SetLink < ActiveRecord::Base
  def self.table_name_prefix
    "media_"
  end
  
  # TODO use dagnabit gem instead ??
  acts_as_dag_links :node_class_name => 'Media::Set'  

  validate :validations
  
  def validations
    errors.add_to_base("A collection cannot be nested") if descendant.type == "Media::Collection"
  end


end
