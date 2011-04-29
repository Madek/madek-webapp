class SearchController < ApplicationController
  
  def show
    @search_term = params[:query]
    viewable_media_entry_ids = current_user.accessible_resource_ids
    viewable_media_set_ids = current_user.accessible_resource_ids(:view, "Media::Set")
    
    params[:per_page] ||= PER_PAGE.first
    
    @active_bookmark = if params[:media_entries]
      "#media_entry_tab"
    elsif params[:media_sets]
      "#set_tab"
    elsif params[:projects]
      "#project_tab"
    end
    
    #TODO# Use seach_for_ids method and do intersection with viewable_ids after the search

    @media_entry_filter = Filter.new(params[:media_entries] || {})
    me_options = {:sphinx_select => "*, (IN (sphinx_internal_id, #{viewable_media_entry_ids.join(',')}) AND class_crc = #{MediaEntry.to_crc32}) AS viewable"}
    me_options.merge!(@media_entry_filter.to_query_filter)
    @media_entries = MediaEntry.search(@search_term, me_options).paginate(:page => params[:page], :per_page => params[:per_page])
    @media_entries_json = Logic.enriched_resource_data(@media_entries, current_user, "MediaEntry").to_json


    @media_set_filter = Filter.new(params[:media_sets] || {})
    set_options = {:sphinx_select => "*, (IN (sphinx_internal_id, #{viewable_media_set_ids.join(',')}) AND class_crc = #{Media::Set.to_crc32}) AS viewable"}
    set_options.merge!(@media_set_filter.to_query_filter)
    set_options[:with].merge!(:media_type => "Set".to_crc32)
    
    @media_sets = Media::Set.search(@search_term, set_options).paginate(:page => params[:page], :per_page => params[:per_page])
    @media_sets_json = Logic.enriched_resource_data(@media_sets, current_user, "Media::Set").to_json

    @project_filter = Filter.new(params[:projects] || {})
    project_options = {:sphinx_select => "*, (IN (sphinx_internal_id, #{viewable_media_set_ids.join(',')}) AND class_crc = #{Media::Set.to_crc32}) AS viewable"}
    project_options.merge!(@project_filter.to_query_filter)
    project_options[:with].merge!(:media_type => "Project".to_crc32)
    @projects = Media::Set.search(@search_term, project_options).paginate(:page => params[:page], :per_page => params[:per_page])
    @projects_json = Logic.enriched_resource_data(@projects, current_user, "Media::Project").to_json
      
    respond_to do |format|
      format.html
      #TODO: # Separate Ajax pagination for MediaEntries, Sets and Projects. Right now not working at all
      format.js { render :json => @json }
      format.xml { render :xml=> @media_entries.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end
  end
    
  
end
