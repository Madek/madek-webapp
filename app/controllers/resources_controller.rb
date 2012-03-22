# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  # TODO cancan # load_resource #:class => "MediaResource"
  before_filter :except => [:index, :filter] do
    begin
      unless (params[:media_resource_id] ||= params[:id] || params[:media_resource_ids]).blank?
        @media_resource = MediaResource.accessible_by_user(current_user).find(params[:media_resource_id])
      end
    rescue
      not_authorized!
    end
  end

###################################################################################

  def index(type = params[:type],
            top_level = params[:top_level],
            user_id = params[:user_id],
            not_by_current_user = params[:not_by_current_user],
            public = params[:public],
            query = params[:query],
            page = params[:page],
            per_page = (params[:per_page] || PER_PAGE.first).to_i,
            meta_key_id = params[:meta_key_id],
            meta_term_id = params[:meta_term_id] )
            
    resources = if request.fullpath =~ /favorites/
      current_user.favorites
    else
      MediaResource
    end

    resources = case type
      when "media_sets"
        r = resources.where(:type => "MediaSet")
        r = r.top_level if top_level
        r
      when "media_entries"
        resources.where(:type => "MediaEntry")
      else
        resources.media_entries_and_media_sets
    end.accessible_by_user(current_user).order("media_resources.updated_at DESC")

    resources = resources.by_user(@user) if user_id and (@user = User.find(user_id))
    if not_by_current_user
      resources = resources.not_by_user(current_user)
      case public
        when "true"
          resources = resources.where(:view => true)
        when "false"
          resources = resources.where(:view => false)
      end
    end
    
    resources = resources.search(query) unless query.blank?
    resources = resources.paginate(:page => page, :per_page => per_page)

    # TODO ?? resources = resources.includes(:meta_data, :permissions)

    if meta_key_id and meta_term_id
      meta_key = MetaKey.find(meta_key_id)
      meta_term = meta_key.meta_terms.find(meta_term_id)
      media_resource_ids = meta_term.meta_data(meta_key).collect(&:media_resource_id)
      resources = resources.where(:id => media_resource_ids)
    end
    
    with_thumb = true #FE# (params[:thumb].to_i > 0)
    
    @resources = { :pagination => { :current_page => resources.current_page,
                                   :per_page => resources.per_page,
                                   :total_entries => resources.total_entries,
                                   :total_pages => resources.total_pages },
                  :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) }
                   
    respond_to do |format|
      format.html
      format.json { render :json => @resources }
    end
  end

  def show
    redirect_to @media_resource
  end
  
  # TODO merge search and filter methods ??
  def filter(query = params[:query],
             page = params[:page],
             per_page = (params[:per_page] || PER_PAGE.first).to_i,
             meta_key_id = params[:meta_key_id],
             meta_term_id = params[:meta_term_id],
             filter = params[:filter] )
             
    # TODO generic search for both MediaResource.media_entries_and_media_sets
    resources = MediaEntry.accessible_by_user(current_user)
 
    if request.post?
      if meta_key_id and meta_term_id
        meta_key = MetaKey.find(meta_key_id)
        meta_term = meta_key.meta_terms.find(meta_term_id)
        media_resource_ids = meta_term.meta_data(meta_key).collect(&:media_resource_id)
      else
        if params["MediaEntry"] and params["MediaEntry"]["media_type"]
          resources = resources.filter_media_file(params["MediaEntry"])
        end
        media_resource_ids = filter[:ids].split(',').map(&:to_i) 
      end
  
      with_thumb = true #FE# (params[:thumb].to_i > 0)

      resources = resources.where(:id => media_resource_ids).paginate(:page => page, :per_page => per_page)
      @resources = { :pagination => { :current_page => resources.current_page,
                                     :per_page => resources.per_page,
                                     :total_entries => resources.total_entries,
                                     :total_pages => resources.total_pages },
                    :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
  
      respond_to do |format|
        format.json { render :json => @resources.to_json }
      end

    else

      @_media_entry_ids = resources.search(query).map(&:id)
  
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
      format.json { 
        render :json => child_resources.as_json(:user => current_user, :methods => :parent_ids) 
      }
    end
  end

###################################################################################

  def image(size = (params[:size] || :large).to_sym)
    # TODO dry => Resource#thumb_base64 and Download audio/video
    media_file = if @media_resource.is_a? MediaSet
      @media_resource.media_entries.accessible_by_user(current_user).order("media_resources.updated_at DESC").first.try(:media_file)
    else
      @media_resource.media_file
    end
    
    unless media_file
      # empty gif pixel
      output = "R0lGODlhAQABAIAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==\n"
      send_data Base64.decode64(output), :type => "image/gif", :disposition => 'inline'
    else
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
  end  

end
