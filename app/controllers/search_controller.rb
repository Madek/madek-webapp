class SearchController < ApplicationController
  
  def show
    viewable_media_entry_ids = current_user.accessible_resource_ids
    viewable_media_set_ids = current_user.accessible_resource_ids(:view, "Media::Set")
    
    params[:per_page] ||= PER_PAGE.first
    
    @active_filter_type = params[:klass]
    @active_bookmark = case @active_filter_type
      when "MediaEntry"
        "#media_entry_tab"
      when "Media::Set"
        "#set_tab"
      when "Media::Project"
        "#project_tab"
    end

    filter_ids = if params[:filter_ids] # TODO resource_type
      params[:filter_ids].inject(nil) do |a, x|
        b = x.split(',').collect(&:to_i)
        a ? a &= b : a = b
      end
    else
      nil
    end

    resource_type = "MediaEntry"
    @media_entry_filter = Filter.new(params[resource_type]) 
    search_options = @media_entry_filter.to_query_filter
    search_result = MediaEntry.search_for_ids(params[:query], search_options)
    @_media_entry_ids = (search_result & viewable_media_entry_ids)
    @_media_entry_ids &= filter_ids unless filter_ids.blank? 
    @paginated_media_entry_ids = @_media_entry_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_entries = Logic.enriched_resource_data(@paginated_media_entry_ids, current_user, resource_type)
    
    resource_type = "Media::Set"
    @media_set_filter = Filter.new(params[resource_type])
    search_options = @media_set_filter.to_query_filter
    search_options[:with].merge!(:media_type => "Set".to_crc32)
    search_result = Media::Set.search_for_ids(params[:query], search_options)
    @_media_set_ids = (search_result & viewable_media_set_ids)
    @_media_set_ids &= filter_ids unless filter_ids.blank? 
    @paginated_media_set_ids = @_media_set_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_sets = Logic.enriched_resource_data(@paginated_media_set_ids, current_user, resource_type)
    
    resource_type = "Media::Project"
    @project_filter = Filter.new(params[resource_type])
    search_options = @project_filter.to_query_filter
    search_options[:with].merge!(:media_type => "Project".to_crc32)
    search_result = Media::Set.search_for_ids(params[:query], search_options)
    @_media_project_ids = (search_result & viewable_media_set_ids)
    @_media_project_ids &= filter_ids unless filter_ids.blank? 
    @paginated_project_ids = @_media_project_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @projects = Logic.enriched_resource_data(@paginated_project_ids, current_user, resource_type)
          
    respond_to do |format|
      format.html
      format.js { 
        render :json => case params[:page_type]
          when "media_entry_tab"
            @media_entries.to_json
          when "set_tab"
            @media_sets.to_json
          when "project_tab"
            @projects.to_json
        end
      }
      format.xml { render :xml => @media_entries.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end
  end
    
  
end
