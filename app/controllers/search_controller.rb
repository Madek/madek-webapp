class SearchController < ApplicationController

  def new
    search_result = ThinkingSphinx.search_for_ids params[:query], :classes => [MediaEntry, Media::Set, Media::Project]
    search_result2 = ThinkingSphinx.facets params[:query]

    debugger
    
    render :text => "temp"
  end

#######################################

#=begin # TODO remove
  def show
    viewable_media_entry_ids = current_user.accessible_resource_ids
    viewable_media_set_ids = current_user.accessible_resource_ids(:view, "Media::Set")
    
    params[:per_page] ||= PER_PAGE.first
    
    resource_type = "MediaEntry"
    search_options = Filter.new(params[resource_type]).to_query_filter
    search_result = MediaEntry.search_for_ids(params[:query], search_options)
    @_media_entry_ids = (search_result & viewable_media_entry_ids)
    @paginated_media_entry_ids = @_media_entry_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_entries = Logic.enriched_resource_data(@paginated_media_entry_ids, current_user, resource_type)
    
    resource_type = "Media::Set"
    search_options = Filter.new(params[resource_type]).to_query_filter
    search_options[:with].merge!(:media_type => "Set".to_crc32)
    search_result = Media::Set.search_for_ids(params[:query], search_options)
    @_media_set_ids = (search_result & viewable_media_set_ids)
    @paginated_media_set_ids = @_media_set_ids.paginate(:page => params[:page], :per_page => params[:per_page])
    @media_sets = Logic.enriched_resource_data(@paginated_media_set_ids, current_user, resource_type)
    
    resource_type = "Media::Project"
    search_options = Filter.new(params[resource_type]).to_query_filter
    search_options[:with].merge!(:media_type => "Project".to_crc32)
    search_result = Media::Set.search_for_ids(params[:query], search_options)
    @_media_project_ids = (search_result & viewable_media_set_ids)
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
    end
  end
#=end  
    
  def filter
    params[:per_page] ||= PER_PAGE.first

    if params[:meta_key_id] and params[:meta_term_id]
      viewable_ids = current_user.accessible_resource_ids
      meta_key = MetaKey.find(params[:meta_key_id])
      meta_term = meta_key.meta_terms.find(params[:meta_term_id])
      media_entry_ids = meta_term.meta_data(meta_key).select{|md| md.resource_type == "MediaEntry"}.collect(&:resource_id)
      intersected_ids = media_entry_ids & viewable_ids 
      paginated_ids = intersected_ids.paginate(:page => params[:page], :per_page => params[:per_page].to_i)
      @resources = Logic.data_for_page(paginated_ids, current_user)
    else
      case params[:filter][:type]
        when "MediaEntry"
          viewable_ids = current_user.accessible_resource_ids
          # TODO merge search and filter methods
          if params["MediaEntry"]["media_type"]
            search_options = Filter.new(params["MediaEntry"]).to_query_filter
            search_result = MediaEntry.search_for_ids(params[:query], search_options)
            viewable_ids = search_result.to_a & viewable_ids
          end
        when "Media::Set", "Media::Project"
          viewable_ids = current_user.accessible_resource_ids(:view, "Media::Set")
      end
      intersected_ids = params[:filter][:ids].split(',').map(&:to_i) & viewable_ids 
      @paginated_ids = intersected_ids.paginate(:page => params[:page], :per_page => params[:per_page])
      @resources = Logic.enriched_resource_data(@paginated_ids, current_user, params[:filter][:type])
    end

    respond_to do |format|
      format.js { render :json => @resources.to_json }
    end    
  end
  
end
