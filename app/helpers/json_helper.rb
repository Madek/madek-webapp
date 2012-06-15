# -*- encoding : utf-8 -*-
module JsonHelper

  def render_json(source, type)
    action = source.is_a?(Array) ? :index : :show 
    partial = [type, action].join('/')
    
    with = case type
      when :media_resources
        { :media_type => true,
          :image=>{:as=>"base64", :size=>"large"},
          :meta_data => {:meta_context_names => ["core"]}}
      else
        {}
    end
    
    render(:partial => "#{partial}",:formats => [:json], :handlers => [:rjson], :locals => {type => source, :with => with})
  end
  
end
