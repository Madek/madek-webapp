# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  def index
    params[:per_page] ||= PER_PAGE.first

    # TODO refactor Resource to STI ??
    klasses = [MediaEntry, Media::Set]
    h = {}
    klasses.each do |klass|
      crc32 = klass.to_crc32
      h[crc32] = {:klass => klass}
      [:view, :edit, :manage].each do |action|
        h[crc32][action] = current_user.accessible_resource_ids(action, klass)
      end 
    end

    result_ids = ThinkingSphinx.search_for_ids params[:query], {:classes => klasses, :per_page => (2**30), :star => true }

    accessible_matches = result_ids.results[:matches].select do |match|
      id = match[:attributes]["sphinx_internal_id"].to_i
      crc32 = match[:attributes]["class_crc"].to_i
      h[crc32][:view].include?(id)
    end

    paginated_matches = accessible_matches.paginate(:page => params[:page], :per_page => params[:per_page].to_i)
    
    # prefetch records
    klasses.each do |klass|
      ids = paginated_matches.select {|x| x[:attributes]["class_crc"] == klass.to_crc32}.map {|x| x[:attributes]["sphinx_internal_id"].to_i}
      klass.find(ids)
    end
    favorite_ids = current_user.favorite_ids
    
    @json = { :pagination => { :current_page => paginated_matches.current_page,
                               :per_page => paginated_matches.per_page,
                               :total_entries => paginated_matches.total_entries,
                               :total_pages => paginated_matches.total_pages },
      :entries => paginated_matches.map do |match|
                    id = match[:attributes]["sphinx_internal_id"].to_i
                    crc32 = match[:attributes]["class_crc"].to_i
                    me = h[crc32][:klass].find(id)
                    flags = { :is_private => me.acl?(:view, :only, current_user),
                              :is_public => me.acl?(:view, :all),
                              :is_editable => h[crc32][:edit].include?(me.id),
                              :is_manageable => h[crc32][:manage].include?(me.id),
                              :can_maybe_browse => !me.meta_data.for_meta_terms.blank?,
                              :is_set => me.is_a?(Media::Set),
                              :is_favorite => current_user.favorite_ids.include?(me.id) }
                    me.attributes.merge(me.get_basic_info(current_user)).merge(flags)
                  end }.to_json 

    respond_to do |format|
      format.html
      format.js { render :json => @json }
    end

  end

end
