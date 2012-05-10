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
  # @optional [Array] with[meta_data][meta_context_names] Adds all requested MetaContexts in the format: ["context_name1", "context_name2", ...] as MetaData to the responding MediaResources. 
  # @optional [Array] with[meta_data][meta_key_names] Adds all requested MetaKeys in the format: ["key_name1", "key_name2", ...] as MetaData to the responding MediaResources. 
  # @optional [Boolean] with[filename] Request the filename of the MediaResources.
  # @optional [Boolean] with[media_type] Request the media_type of the MediaResources.
  # @optional [Boolean] with[flags] Request status indicator informations (about permissions and favorites related to the current user) for the responding MediaResources.
  #
  # @example_request {"ids": [1,2,3]}
  # @example_response {"media_resources:": [{"id":1}, {"id":2}, {"id":3}], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"with": {"meta_data": {"meta_context_names": ["core"]}}}
  # @example_request_description Requests MediaResources with all nested MetaData for the MetaContext with the name "core". 
  # @example_response {"media_resources:": [{"id":1, "meta_data": {"title": "My new Picture", "author": "Musterman, Max", "portrayed_object_dates": null, "keywords": "picture, portrait", "copryright_notice"}}, ...], "pagination": {"total": 100, "page": 1, "per_page": 36, "total_pages": 2}}
  #
  # @example_request {"with": {"meta_data": {"meta_key_names": ["title", "author"]}}}
  # @example_request_description Requests MediaResources with all nested MetaData for the MetaKeys with the name "title" and "author". 
  # @example_response {"media_resources:": [{"id":1, "meta_data": {"title": "My new Picture", "author": "Musterman, Max"}, ...]}
  #
  # @example_request {"ids": [1,2,3], "with": {"image": {"as": "base64"}}} 
  # @example_request_description Is requesting MediaResources with id 1,2 and 3. Adds an image as base64 to the respond.
  # @example_response {"media_resources:": [{"id":1, "image": ""data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/4gxYSUNDX1BST0ZJTEUAAQEAAAxITGlu bwIQAABtbnRyUkdCIFhZWiAHzgACAAkABgAxAABhY3NwTVNG"}, ...], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"ids": [1,2,3], "with": {"filename": true}}
  # @example_request_description Request MediaResources with filenames
  # @example_response {"media_resources:": [{"id":1, "filename": "my_file_name.jpg"}, {"id":2, "filename": "my_2_file_name.jpg"}, {"id":3, "filename": "my_3_file_name.jpg"}], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"ids": [1,2,3], "with": {"media_type": true}}
  # @example_request_description Request MediaResources with MediaTypes
  # @example_response {"media_resources:": [{"id":1, "media_type": "Image"}, {"id":2, "media_type": "Image"}, {"id":3, "media_type": "Image"}], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"ids": [1,2,3], "with": {"flags": true}}
  # @example_request_description Request MediaResources with flags.
  # @example_response {"media_resources:": [{"id":1, "is_public": true, "is_private": false, "is_shared": false, "is_editable": true, "is_managable": true, "is_favorite": false}, ...], "pagination": ...}
  # @example_request_description The responding MediaResource with id 1 is accesible by everyone and is editable, managable by the current user. The MediaResource is not part of the current user's favorites.
  #
  # @response_field [Integer] id The id of the MediaResource  
  # @response_field [Hash] meta_data The MetaData of the MediaResource (To get a list of possible MetaData - or the schema - you have to consider the MetaDatum resource)
  # @response_field [String] filename The Filename of a MediaEntry's MediaFile (in case of MediaSets its null) 
  # @response_field [String] media_type The Mediatype of a Media Resource (Video, Audio, Image or Doc;in case of MediaSets its Set) 
  # @response_field [Boolean] is_public The is_public status.
  # @response_field [Boolean] is_private The is_private status.
  # @response_field [Boolean] is_shared The is_shared status.
  # @response_field [Boolean] is_editable The is_editable status.
  # @response_field [Boolean] is_managable The is_managable status.
  # @response_field [Boolean] is_favorite The is_fa status.
  #
  def index(ids = (params[:collection_id] ? MediaResource.by_collection(current_user.id, params[:collection_id]) : params[:ids]),
            type = params[:type],
            with = params[:with] || {},
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

        @media_resources = resources
        @with = with
      }
    end
  end

  def show
    redirect_to @media_resource
  end

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
      format.json { 
        render :partial => "media_resources/index.json.rjson", :locals => {:media_resources => child_resources, :with => {:parents => true}}
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
             type = params[:type],
             with = params[:with] || {},
             page = params[:page],
             per_page = (params[:per_page] || PER_PAGE.first).to_i,
             meta_key_id = params[:meta_key_id],
             meta_term_id = params[:meta_term_id],
             filter = params[:filter] )

    where_type = case type
      when "media_sets"
        "MediaSet"
      when "media_entries"
        "MediaEntry"
      else
        ["MediaEntry", "MediaSet"]
    end
    resources = MediaResource.accessible_by_user(current_user).where(:type => where_type)
 
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

      if params[:owner_id] and (not params[:owner_id].empty?)
        resources = resources.where("user_id in (?) ", params[:owner_id].map(&:to_i))
      end

      if params[:group_id] and (not params[:group_id].empty?)
        resources = resources.where( %Q< media_resources.id  in (
          #{MediaResource
             .grouppermissions_not_disallowed(current_user, :view)
             .where("grouppermissions.group_id in ( ? )",params[:group_id].map(&:to_i))
             .select("media_resource_id").to_sql})>)
      end

      unless params[:permission_preset].blank? 
        presets = PermissionPreset.where(" id in ( ? )",  params[:permission_preset].map(&:to_i))
        resources = MediaResource.where_permission_presets_and_user presets, current_user
      end

      resources = resources.paginate(:page => page, :per_page => per_page)

      respond_to do |format|
        format.json {
          @media_resources = resources
          @with = with
          render :template => "media_resources/index.json.rjson"
        }
      end

    else

      @resources = resources.search(query)

      @owners = User.joins(:person)
        .select("users.id as user_id, people.lastname as lastname, people.firstname as firstname")
        .where("users.id in (#{resources.search(query).select("media_resources.user_id").to_sql}) ")
        .order("lastname, firstname DESC")

      @groups = Group.where( %Q< groups.id in ( 
          #{MediaResource.grouppermissions_not_disallowed(current_user, :view).select("grouppermissions.group_id").to_sql}
          )>) 
        .order("name ASC")

      @permission_presets = PermissionPreset.where (Constants::Actions.reduce(" false ") { |s,action| s + " OR #{action} = true" }) 

      respond_to do |format|
        format.html { render :layout => false}
      end
    end
  end

end

