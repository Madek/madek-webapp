# -*- encoding : utf-8 -*-
class MediaResourcesController < ApplicationController

  # TODO cancan # load_resource #:class => "MediaResource"
  before_filter :except => [:index, :collection] do
    begin
      unless (params[:media_resource_id] ||= params[:id] || params[:media_resource_ids]).blank?
        @media_resource = MediaResource.accessible_by_user(current_user).find(params[:media_resource_id])
      end
    rescue
      not_authorized!
    end
  end

###################################################################################

  ##
  # Get a collection of MediaResources
  # 
  # @resource /media_resources
  #
  # @action GET
  # 
  # @optional [Array] ids A collection of MediaResources you want to fetch informations for 
  #
  # @optional [Hash] with[meta_data] Adds MetaData to the responding collection of MediaResources and forwards the hash as options to the MetaData.
  # @optional [Array] with[meta_data][meta_contexts] Adds all requested MetaContexts as MetaData to the responding MediaResources. 
  # @optional [Hash] with[meta_data][meta_contexts][].name The name of the MetaContext which MetaData should be added to the responding MediaResources. 
  #
  # @example_request {"ids": [1,2,3]}
  # @example_response {"media_resources:": [{"id":1}, {"id":2}, {"id":3}], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"with": {"meta_data": {"meta_context_names": ["core"]}}}
  # @example_request_description Requests MediaResources with all nested MetaData for the MetaContext with the name "core". 
  # @example_response {"media_resources:": [{"id":1, "meta_data": {"title": "My new Picture", "author": "Musterman, Max", "portrayed_object_dates": null, "keywords": "picture, portrait", "copryright_notice"}}, ...], "pagination": {"total": 100, "page": 1, "per_page": 36, "total_pages": 2}}
  #
  # @example_request {"ids": [1,2,3], "with": {"image": {"as": "base64"}}} 
  # @example_request_description Is requesting MediaResources with id 1,2 and 3. Adds an image as base64 to the respond.
  # @example_response {"media_resources:": [{"id":1, "image": ""data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/4gxYSUNDX1BST0ZJTEUAAQEAAAxITGlu bwIQAABtbnRyUkdCIFhZWiAHzgACAAkABgAxAABhY3NwTVNG"}, ...], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"ids": [1,2,3], "with": {"filename": true}}
  # @example_request_description Request MediaResources with filenames
  # @example_response {"media_resources:": [{"id":1, "filename": "my_file_name.jpg"}, {"id":2, "filename": "my_2_file_name.jpg"}, {"id":3, "filename": "my_3_file_name.jpg"}], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @response_field [Integer] [].id The id of the MediaResource  
  # @response_field [Hash] [].meta_data The MetaData of the MediaResource (To get a list of possible MetaData - or the schema - you have to consider the MetaDatum resource)
  # @response_field [String] [].filename The Filename of a MediaEntry's MediaFile (in case of MediaSets its null) 
  #
  def index(ids = (params[:collection_id] ? MediaResource.by_collection(current_user.id, params[:collection_id]) : params[:ids]),
            type = params[:type],
            top_level = params[:top_level],
            user_id = params[:user_id],
            media_set_id = params[:media_set_id],
            not_by_current_user = params[:not_by_current_user],
            public = params[:public],
            favorites = params[:favorites],
            sort = params[:sort] ||= "updated_at",
            query = params[:query],
            page = params[:page],
            per_page = [(params[:per_page] || PER_PAGE.first).to_i, PER_PAGE.first].min,
            meta_key_id = params[:meta_key_id],
            meta_term_id = params[:meta_term_id] )

    respond_to do |format|
      format.html
      format.json {

        resources = if favorites == "true"
            current_user.favorites
          elsif media_set_id
            MediaSet.find(media_set_id).children
          else
            MediaResource
          end

        resources = resources.where(:id => ids) if ids
    
        resources = case type
          when "media_sets"
            r = resources.where(:type => "MediaSet")
            r = r.top_level if top_level
            r
          when "media_entries"
            resources.where(:type => "MediaEntry")
          when "media_entry_incompletes"
            resources.where(:type => "MediaEntryIncomplete")
          else
            if ids
              resources.where(:type => ["MediaEntry", "MediaSet", "MediaEntryIncomplete"])
            else
              resources.where(:type => ["MediaEntry", "MediaSet"])
            end
        end.accessible_by_user(current_user)

        case sort
          when "updated_at", "created_at"
            resources = resources.order("media_resources.#{sort} DESC")
          when "random"
            if SQLHelper.adapter_is_mysql?
              resources = resources.order("RAND()")
            elsif SQLHelper.adapter_is_postgresql? 
              resources = resources.order("RANDOM()")
            else
              raise "SQL Adapter is not supported" 
            end
        end

        resources = resources.by_user(@user) if user_id and (@user = User.find(user_id))
        # FIXME use presets and :manage permission
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
        
        # FIXME merge json response
        if ids # using API for meta_data and permissions
          @media_resources = resources
        else
          # TODO drop this 
          render :json => { :pagination => { :page => resources.current_page,
                                             :per_page => resources.per_page,
                                             :total => resources.total_entries,
                                             :total_pages => resources.total_pages },
                            :media_resources => resources.as_json(:user => current_user, :with_thumb => true) }
        end
      }
    end
  end

  def show
    redirect_to @media_resource
  end

=begin
  def update
    
    ActiveRecord::Base.transaction do

      begin

        @media_resource = MediaResource.find(params[:id])
        
        raise "user is not allowed to update resource" unless current_user == @media_resource.user

        if @media_resource.type == "MediaEntryIncomplete" and params[:media_resource][:type] == "MediaEntry"
          @media_resource.set_as_complete
        end

        @media_resource.update_attributes!(params[:media_resource])

        respond_to do |format|
          format.json { head :no_content }
        end

      rescue Exception => e

        respond_to do |format|
          format.json { render json: e, status: :unprocessable_entity }
        end

      end

    end

  end
=end

########################################################################

  def collection(ids = params[:ids],
                 collection_id = params[:collection_id])
    if request.post? and ids
      collection_id = Time.now.to_i
      Rails.cache.write({user: current_user.id, collection: collection_id}, ids, expires_in: 1.week)
    #elsif request.delete? and collection_id
    #  collection_id = session[:media_resource_ids][collection_id] = nil
    #elsif request.get? and collection_id
    else
      raise "error"
    end

    respond_to do |format|
      format.json { render json: {collection_id: collection_id} }
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
        output = media_file.thumb_placeholder
        send_data output, :type => "image/png", :disposition => 'inline'
      end
    end
  end  

###################################################################################

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
  
      resources = resources.where(:id => media_resource_ids)

      unless params[:owner_id].empty?
        resources = resources.where("user_id in (?) ", params[:owner_id].map(&:to_i))
      end

      resources= resources.paginate(:page => page, :per_page => per_page)

      @resources = { :pagination => { :page => resources.current_page,
                                     :per_page => resources.per_page,
                                     :total => resources.total_entries,
                                     :total_pages => resources.total_pages },
                    :media_resources => resources.as_json(:user => current_user, :with_thumb => true) } 
  
      respond_to do |format|
        format.json { render :json => @resources.to_json }
      end

    else

      @resources = resources.search(query)

      @owners = User.joins(:person)
        .select("users.id as user_id, people.lastname as lastname, people.firstname as firstname")
        .where("users.id in (#{resources.search(query).select("media_resources.user_id").to_sql}) ")
        .order("lastname, firstname DESC")

      respond_to do |format|
        format.html { render :layout => false}
      end
    end
  end

end

