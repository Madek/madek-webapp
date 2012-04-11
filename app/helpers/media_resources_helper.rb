# -*- encoding : utf-8 -*-
module MediaResourcesHelper
  
  def media_resources_index_title
    case current_settings
      
      when {:type => :all, :permissions => :all}
        "Alle Inhalte"
      when {:type => :media_entries, :permissions => :all}
        "Alle Medieneinträge"
      when {:type => :media_sets, :permissions => :all}
        "Alle Sets"
        
      when {:type => :all, :permissions => :mine}
        "Meine Inhalte"
      when {:type => :media_entries, :permissions => :mine}
        "Meine Medieneinträge"
      when {:type => :media_sets, :permissions => :mine}
        "Meine Sets"
        
      when {:type => :all, :permissions => :entrusted}
        "Mir anvertraute Inhalte"
      when {:type => :media_entries, :permissions => :entrusted}
        "Mir anvertraute Medieneinträge"
      when {:type => :media_sets, :permissions => :entrusted}
        "Mir anvertraute Sets"
        
      when {:type => :all, :permissions => :public}
        "Öffentliche Inhalte"
      when {:type => :media_entries, :permissions => :public}
        "Öffentliche Medieneinträge"
      when {:type => :media_sets, :permissions => :public}
        "Öffentliche Sets"
        
      else
        ""
    end
  end
  
  def current_settings
    h = {}
    
    h[:type] = case params[:type]
      when "media_entries"
        :media_entries
      when "media_sets"
        :media_sets
      else
        :all
    end
    
    h[:permissions] = if (params[:user_id].to_i == current_user.id)
      :mine
    elsif (params[:not_by_current_user] == "true" and params[:public] == "false")
      :entrusted
    elsif (params[:not_by_current_user] == "true" and params[:public] == "true") 
      :public
    else
      :all
    end
    
    h
  end
  
end
