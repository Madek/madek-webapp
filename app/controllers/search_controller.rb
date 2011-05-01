class SearchController < ApplicationController
  
  def show
    @search_term = params[:query]
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

    @media_entry_filter = Filter.new(params["MediaEntry"] || {})
    me_options = @media_entry_filter.to_query_filter
    all_media_entry_ids = MediaEntry.search_for_ids(@search_term, me_options)
    @paginated_media_entry_ids = (all_media_entry_ids & viewable_media_entry_ids).paginate(:page => params[:page], :per_page => params[:per_page])
    @media_entries = MediaEntry.includes(:media_file).where(:id => @paginated_media_entry_ids)
    @media_entries_json = Logic.enriched_resource_data(@paginated_media_entry_ids, @media_entries, current_user, "MediaEntry").to_json
    
    @media_set_filter = Filter.new(params["Media::Set"] || {})
    set_options = @media_set_filter.to_query_filter
    set_options[:with].merge!(:media_type => "Set".to_crc32)
    all_media_set_ids = Media::Set.search_for_ids(@search_term, set_options)
    @paginated_media_set_ids = (all_media_set_ids & viewable_media_set_ids).paginate(:page => params[:page], :per_page => params[:per_page])
    @media_sets = Media::Set.where(:id => @paginated_media_set_ids)
    @media_sets_json = Logic.enriched_resource_data(@paginated_media_set_ids, @media_sets, current_user, "Media::Set").to_json
    
    @project_filter = Filter.new(params["Media::Project"] || {})
    project_options = @project_filter.to_query_filter
    project_options[:with].merge!(:media_type => "Project".to_crc32)
    all_project_ids = Media::Set.search_for_ids(@search_term, project_options)
    @paginated_project_ids = (all_project_ids & viewable_media_set_ids).paginate(:page => params[:page], :per_page => params[:per_page])
    @projects = Media::Project.where(:id => @paginated_project_ids)
    @projects_json = Logic.enriched_resource_data(@paginated_project_ids, @projects, current_user, "Media::Project").to_json
          
    respond_to do |format|
      format.html
      format.js { 
        page_to_render = case params[:page_type]
          when "media_entry"
            @media_entries_json
          when "set"
            @media_sets_json
          when "project"
            @projects_json
        end
        render :json => page_to_render
      }
      format.xml { render :xml=> @media_entries.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end
  end
    
  
end
