class SearchController < ApplicationController
  
  def show
    viewable_media_entry_ids = current_user.accessible_resource_ids
    viewable_media_set_ids = current_user.accessible_resource_ids(:view, "Media::Set")
    
    params[:per_page] ||= PER_PAGE.first
    
    resource_type = "MediaEntry"
    @media_entry_filter = Filter.new(params[resource_type]) 
    search_options = @media_entry_filter.to_query_filter
    search_result = MediaEntry.search_for_ids(params[:query], search_options)
    @_media_entry_ids = (search_result & viewable_media_entry_ids)
    @paginated_media_entry_ids = @_media_entry_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_entries = Logic.enriched_resource_data(@paginated_media_entry_ids, current_user, resource_type)
    
    resource_type = "Media::Set"
    @media_set_filter = Filter.new(params[resource_type])
    search_options = @media_set_filter.to_query_filter
    search_options[:with].merge!(:media_type => "Set".to_crc32)
    search_result = Media::Set.search_for_ids(params[:query], search_options)
    @_media_set_ids = (search_result & viewable_media_set_ids)
    @paginated_media_set_ids = @_media_set_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_sets = Logic.enriched_resource_data(@paginated_media_set_ids, current_user, resource_type)
    
    resource_type = "Media::Project"
    @project_filter = Filter.new(params[resource_type])
    search_options = @project_filter.to_query_filter
    search_options[:with].merge!(:media_type => "Project".to_crc32)
    search_result = Media::Set.search_for_ids(params[:query], search_options)
    @_media_project_ids = (search_result & viewable_media_set_ids)
    @paginated_project_ids = @_media_project_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @projects = Logic.enriched_resource_data(@paginated_project_ids, current_user, resource_type)

    respond_to do |format|
      format.html { @editable_sets = Media::Set.accessible_by(current_user, :edit) }
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
    end
  end
    
  def filter
    viewable_media_entry_ids = current_user.accessible_resource_ids # TODO before_filter

    resource_type = "MediaEntry"
    @_media_entry_ids = viewable_media_entry_ids & params[:filter_ids].split(',').map(&:to_i) 
    @paginated_media_entry_ids = @_media_entry_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_entries = Logic.enriched_resource_data(@paginated_media_entry_ids, current_user, resource_type)

    #@_media_set_ids &= filter_ids unless filter_ids.blank? 
    #@_media_project_ids &= filter_ids unless filter_ids.blank? 

    respond_to do |format|
      format.js { render :json => @media_entries.to_json }
    end    
  end
  
end
