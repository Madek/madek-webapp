class SearchController < ApplicationController
  
  def show
    @search_term = params[:query].blank? ? nil : params[:query]
    viewable_media_entry_ids = current_user.accessible_resource_ids
    viewable_media_set_ids = current_user.accessible_resource_ids(:view, Media::Set)
    options = {:sphinx_select => "*, (IN (sphinx_internal_id, #{viewable_media_entry_ids.join(',')}) AND class_crc = #{MediaEntry.to_crc32}) 
    OR (IN (sphinx_internal_id, #{viewable_media_set_ids.join(',')}) AND class_crc = #{Media::Set.to_crc32}) AS viewable"}
    
    params[:per_page] ||= PER_PAGE.first
    @filter = Filter.new(params[:filter] || {})
    options.merge!(@filter.to_query_filter)
    #tmp # eventually we want to figure out which classes we need to limit the search to (based on filter attributes/fields)
    options.merge!(:classes => [MediaEntry]) if !@filter.filters.empty?

    @media = ThinkingSphinx.search(@search_term, options).paginate(:page => params[:page], :per_page => params[:per_page])
    
    @json = Logic.enriched_resource_data(@media, current_user).to_json
    
    @facets = ThinkingSphinx.facets(@search_term, options)
    
    respond_to do |format|
      format.html
      format.js { render :json => @json }
      format.xml { render :xml=> @media_entries.to_xml(:include => {:meta_data => {:include => :meta_key}} ) }
    end
  end
  
end
