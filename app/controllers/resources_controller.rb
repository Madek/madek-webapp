# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  # TODO cancan # load_resource #:class => "MediaResource"

  def index
    params[:per_page] ||= PER_PAGE.first

    resources = MediaResource.accessible_by_user(current_user)
    if params[:type]
      resources = resources.send(params[:type])
    else
      resources = resources.where(:type => ["MediaEntry", "MediaSet"])
    end

    resources = resources.by_user(@user) if params[:user_id] and (@user = User.find(params[:user_id]))
    resources = resources.not_by_user(current_user) if params[:not_by_current_user]
    resources = resources.favorites_for_user(current_user) if request.fullpath =~ /favorites/
    resources = resources.search(params[:query]) unless params[:query].blank?
    resources = resources.paginate(:page => params[:page], :per_page => params[:per_page].to_i)

    # TODO ?? resources = resources.includes(:meta_data, :permissions)

    if params[:meta_key_id] and params[:meta_term_id]
      meta_key = MetaKey.find(params[:meta_key_id])
      meta_term = meta_key.meta_terms.find(params[:meta_term_id])
      media_resource_ids = meta_term.meta_data(meta_key).collect(&:media_resource_id)
      resources = resources.media_entries.where(:id => media_resource_ids)
    end
    
    with_thumb = true #FE# (params[:thumb].to_i > 0)
    
    @resources = { :pagination => { :current_page => resources.current_page,
                                   :per_page => resources.per_page,
                                   :total_entries => resources.total_entries,
                                   :total_pages => resources.total_pages },
                  :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) }
                   
    respond_to do |format|
      format.html
      format.js { render :json => @resources }
    end
  end
  
  # TODO merge search and filter methods ??
  def filter
    resources = MediaResource.accessible_by_user(current_user)

    if request.post?
      params[:per_page] ||= PER_PAGE.first
  
      if params[:meta_key_id] and params[:meta_term_id]
        meta_key = MetaKey.find(params[:meta_key_id])
        meta_term = meta_key.meta_terms.find(params[:meta_term_id])
        media_resource_ids = meta_term.meta_data(meta_key).collect(&:media_resource_id)
      else
        if params["MediaEntry"] and params["MediaEntry"]["media_type"]
          resources = resources.filter_media_file(params["MediaEntry"])
        end
        media_resource_ids = params[:filter][:ids].split(',').map(&:to_i) 
      end
  
      with_thumb = true #FE# (params[:thumb].to_i > 0)

      resources = resources.media_entries.where(:id => media_resource_ids).paginate(:page => params[:page], :per_page => params[:per_page].to_i)
      @resources = { :pagination => { :current_page => resources.current_page,
                                     :per_page => resources.per_page,
                                     :total_entries => resources.total_entries,
                                     :total_pages => resources.total_pages },
                    :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
  
      respond_to do |format|
        format.js { render :json => @resources.to_json }
      end

    else

      @_media_entry_ids = resources.search(params[:query]).media_entries.map(&:id)
  
      respond_to do |format|
        format.js { render :layout => false}
      end
    end
  end

end
