module Json
  module ApplicationHelper

    def json_for(target, with = nil)
      hash_for(target, with).to_json
    end

    def hash_for(target, with = nil)
      klass = target.class
      case klass.name
        when "Array", "ActiveRecord::Relation", "WillPaginate::Collection"
          # TODO eager loading here for associations ?? 
          target.map do |t|
            hash_for(t, with)
          end
        else
          #TODO with = get_with_preset(with[:preset]).deep_merge(with) if not with.nil? and with[:preset]
          with = with.try(:deep_symbolize_keys)
          send("hash_for_#{klass.name.underscore}", target, with)
      end
    end
    
    #################################################################

    # TODO drop this
    def old_render_json(source, type)
      with = case type
        when :media_resources
          { :media_type => true,
            :image=>{:as=>"base64", :size=>"large"},
            :meta_data => {:meta_context_names => ["core"]}}
        else
          {}
      end
      
      json_for(source, with)
    end

  end
end
