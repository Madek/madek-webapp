# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Arcs

    def self.included(base)
      base.class_eval do
        has_many :out_arcs, :class_name => "MediaResourceArc", :foreign_key => :parent_id
        has_many :in_arcs, :class_name => "MediaResourceArc", :foreign_key => :child_id
  
        has_many :parent_sets, :through => :in_arcs, :source => :parent
      end
    end

    def parents 
      case self.class.model_name.to_s
        when "MediaSet"
          parent_sets
        when "MediaEntry"
          media_sets
        when "FilterSet"
          parent_sets
        when "MediaEntryIncomplete"
          media_sets
        else
          raise "parents is not supported (yet) for your type"
      end
    end


  end
end



