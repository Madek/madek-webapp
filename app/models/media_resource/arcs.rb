# -*- encoding : utf-8 -*-
#
class MediaResource < ActiveRecord::Base

  has_many :out_arcs, :class_name => "MediaResourceArc", :foreign_key => :parent_id
  has_many :in_arcs, :class_name => "MediaResourceArc", :foreign_key => :child_id

  has_many :parent_sets, :through => :in_arcs, :source => :parent


  # TODO move down to MediaSet, it's currently here because the favorites
  scope :top_level, joins("LEFT JOIN media_resource_arcs ON media_resource_arcs.child_id = media_resources.id").
                    where(:media_resource_arcs => {:parent_id => nil})
  
  scope :relative_top_level, select("DISTINCT media_resources.*").
                              joins("LEFT JOIN media_resource_arcs msa ON msa.child_id = media_resources.id").
                              joins("LEFT JOIN media_resources mr2 ON msa.parent_id = mr2.id AND mr2.user_id = media_resources.user_id").
                              where(:mr2 => {:id => nil})

  def parents 
    case type
    when "MediaSet"
      parent_sets
    when "MediaEntry"
      media_sets
    else
      raise "parents is not supported (yet) for your type"
    end
  end

end



