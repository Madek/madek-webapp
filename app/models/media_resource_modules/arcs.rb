# -*- encoding : utf-8 -*-
#

module MediaResourceModules
  module Arcs

    def self.included(base)

      base.has_many :out_arcs, :class_name => "MediaResourceArc", :foreign_key => :parent_id
      base.has_many :in_arcs, :class_name => "MediaResourceArc", :foreign_key => :child_id

      base.has_many :parent_sets, :through => :in_arcs, :source => :parent


      # TODO move down to MediaSet, it's currently here because the favorites
      base.scope :top_level, base.joins("LEFT JOIN media_resource_arcs ON media_resource_arcs.child_id = media_resources.id").
                        where(:media_resource_arcs => {:parent_id => nil})
      
      base.scope :relative_top_level, base.select("DISTINCT media_resources.*").
                                  joins("LEFT JOIN media_resource_arcs msa ON msa.child_id = media_resources.id").
                                  joins("LEFT JOIN media_resources mr2 ON msa.parent_id = mr2.id AND mr2.user_id = media_resources.user_id").
                                  where(:mr2 => {:id => nil})
    end

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

end



