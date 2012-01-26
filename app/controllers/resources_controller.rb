# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  # TODO cancan # load_resource #:class => "MediaResource"
  before_filter :pre_load, :except => [:index, :filter]

  def index
    params[:per_page] ||= PER_PAGE.first

    resources = MediaResource.accessible_by_user(current_user)
    if params[:type]
      resources = resources.send(params[:type])
    else
      resources = resources.media_entries_and_media_sets
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

  def show
    redirect_to @media_resource
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

###################################################################################

  def toggle_favorites
    current_user.favorites.toggle(@media_resource)
    respond_to do |format|
      format.js { render :partial => "favorite_link", :locals => {:media_resource => @media_resource} }
    end
  end

###################################################################################

  def parents(parent_media_set_ids = params[:parent_media_set_ids])
    parent_media_sets = MediaSet.accessible_by_user(current_user, :edit).where(:id => parent_media_set_ids.map(&:to_i))
    child_resources = Array(@media_resource)
    
    child_resources.each do |resource|
      if request.post?
        (parent_media_sets - resource.parent_sets).each do |parent_media_set|
          resource.parent_sets << parent_media_set 
        end
      elsif request.delete?
        parent_media_sets.each do |parent_media_set|
          resource.parent_sets.delete(parent_media_set)
        end
      end
    end
    
    respond_to do |format|
      #format.html { redirect_to @media_set }
      format.js { 
        render :json => child_resources.as_json(:user => current_user, :methods => :parent_ids) 
      }
    end
  end

###################################################################################

  def image(size = params[:size] || :large)
    # TODO dry => Resource#thumb_base64 and Download audio/video
    media_file = if @media_resource.is_a? MediaSet
      @media_resource.media_entries.accessible_by_user(current_user).first.try(:media_file)
    else
      @media_resource.media_file
    end
    
    return unless media_file
    
    preview = media_file.get_preview(size)
    file = File.join(THUMBNAIL_STORAGE_DIR, media_file.shard, preview.filename)
    if File.exist?(file)
      output = File.read(file)
      send_data output, :type => preview.content_type, :disposition => 'inline'
    else
      # OPTIMIZE dry => MediaFile#thumb_base64
      size = (size == :large ? :medium : :small)
      output = File.read("#{Rails.root}/app/assets/images/Image_#{size}.png")
      send_data output, :type => "image/png", :disposition => 'inline'
    end
  end  

###################################################################################

  def pre_load
    params[:media_resource_id] ||= params[:id] ||= params[:media_resource_ids]
    @media_resource = MediaResource.accessible_by_user(current_user).find(params[:media_resource_id]) unless params[:media_resource_id].blank?
  end

end
