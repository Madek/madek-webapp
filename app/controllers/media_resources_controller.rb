# -*- encoding : utf-8 -*-

##
# MediaResources are the core content of MAdeK. They are seperated in MediaEntries and MediaSets (Collection of MediaResources).
# 
class MediaResourcesController < ApplicationController

  # TODO cancan # load_resource #:class => "MediaResource"
  before_filter :except => [:index, :collection] do
    begin
      unless (params[:media_resource_id] ||= params[:id] || params[:media_resource_ids]).blank?
        action = case request[:action].to_sym
          when :edit, :destroy
            :edit
          else
            :view
        end
        @media_resource = MediaResource.accessible_by_user(current_user, action).find(params[:media_resource_id])
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
  # @optional [Array] ids A collection of MediaResources you want to fetch informations for.
  #
  # @optional [String] type Filter the response by MediaResource types: "media_sets" | "media_entries".
  # @optional [String] sort Sort the response (DESC) by: "updated_at"(Default) | "created_at" | "random".
  # @optional [String] query Make a search request which searches in all MetaData of all MediaResources responding with matched MediaResources.
  #
  # @optional [Hash] with[meta_data] Adds MetaData to the responding collection of MediaResources and forwards the hash as options to the MetaData.
  # @optional [Array] with[meta_data][meta_context_names] Adds all requested MetaContexts in the format: ["context_name1", "context_name2", ...] as MetaData to the responding MediaResources. 
  # @optional [Array] with[meta_data][meta_key_names] Adds all requested MetaKeys in the format: ["key_name1", "key_name2", ...] as MetaData to the responding MediaResources. 
  # @optional [Hash] with[image] Request the image of the MediaResources. You can define the responding image format like {"image": {"as": "base64" | "url"}}. The image size can be requested with {"image": {"size": "small"(100x100) | "small_125"(125x125) | "medium"(300x300) | "large"(620x500) | "x_large"(1024x768) }}
  # @optional [Boolean] with[filename] Request the filename of the MediaResources.
  # @optional [Boolean] with[media_type] Request the media_type of the MediaResources.
  # @optional [Boolean] with[flags] Request status indicator informations (about permissions and favorites related to the current user) for the responding MediaResources.
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
  # @response_field [Array] children The children of a MediaResource (only for MediaSets)..
  # @response_field [Array] parents The parents of a MediaResource.
  #
  # @example_request media_resources.json
  # @example_request_description Requesting the index of MediaResources without any attributes.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {"id":1},{"id":2},{"id":3}],
  #     "pagination": {
  #       "total":3,
  #       "page":1,
  #       "per_page":36,
  #       "total_pages":1
  #     }
  #   }
  #   ```
  # @example_response_description Responding with the index of media resources. Default sorting at on the update_at attribute latest first. You get 36 elements per page and informations about the current pagination.
  #
  # @example_request
  #   ```json
  #   {
  #     "ids": [1,2,3]
  #   }
  #   ```
  # @example_request_description Just requesting the MediaResources with id 1,2 and 3.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {"id":1},{"id":2},{"id":3}
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "with": {
  #       "meta_data":{
  #         "meta_context_names": ["core"]
  #       }
  #     }
  #   }
  #   ```
  # @example_request_description Request MediaResources with all nested MetaData for the MetaContext with the name "core".
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "meta_data": {
  #          "title":"My new Picture",
  #          "author":"Max Muster",
  #          "keywords":"picture, portrait"
  #        }
  #     ]
  #   }
  #   ```
  # @example_response_description The attributes of the MetaContext "core" might change, you should get the shema of the context by fetching the "core" context through the MetaContext resource.
  #
  # @example_request
  #   ```json
  #   {
  #     "with": {
  #       "meta_data":{
  #         "meta_key_names": ["title", "author"]
  #       }
  #     }
  #   }
  #   ```
  # @example_request_description Request MediaResources with nested MetaData for the MetaKeys with the name "title" and "author". 
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "meta_data": {
  #          "title":"My new Picture",
  #          "author":"Max Muster"
  #        }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "ids": [1],
  #     "with":{
  #       "image": {
  #         "as":"base64"
  #       }
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with id 1 with nested image as base64.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "image":"data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/4gxYSUNDX1BST0ZJTEUAAQEAAAxITGlu bwIQAABtbnRyUkdCIFhZWiAHzgACAAkABgAxAABhY3NwTVNG"
  #       }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "ids": [1],
  #     "with":{
  #       "filename":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with filenames.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "filename":"my_file_name.jpg"
  #       }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "type":"media_entries"
  #   }
  #   ``` 
  # @example_request_description Request MediaResources but only MediaEntries.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":12,
  #        "type":"media_entry"
  #       },
  #       {
  #        "id":23,
  #        "type":"media_entry"
  #       }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "type":"media_sets"
  #   }
  #   ``` 
  # @example_request_description Request MediaResources but only MediaSets.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":24,
  #        "type":"media_set"
  #       },
  #       {
  #        "id":33,
  #        "type":"media_set"
  #       }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "sort":"updated_at",
  #     "with": {
  #       "updated_at":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources sorted by updated_at (DESC) include the DateTime for updated_at.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":24,
  #        "updated_at": "2012-04-26T11:21:25+02:00"
  #       },
  #       {
  #        "id":21,
  #        "updated_at": "2012-04-25T11:21:22+02:00"
  #       }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "sort":"created_at",
  #     "with": {
  #       "created_at":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources sorted by created_at (DESC) include the DateTime for created_at.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":35,
  #        "created_at": "2012-04-27T11:21:25+02:00"
  #       },
  #       {
  #        "id":21,
  #        "created_at": "2012-04-22T11:21:22+02:00"
  #       }
  #     ]
  #   }
  #   ```
  #
  # @example_request
  #   ```json
  #   {
  #     "query":"blue",
  #     "with": {
  #       "meta_context_names":["core"]
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources which contain "blue" in any of their meta_data responding with nested MetaData of the MetaContext "core".
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "title":"My blue Picture",
  #        "author":"Musterman, Max",
  #        "keywords":"picture, portrait"
  #       },
  #       {
  #        "id":21,
  #        "title":"Red Woods",
  #        "author":"Blue, Adam",
  #        "keywords":"picture, portrait"
  #       },
  #       {
  #        "id":33,
  #        "title":"Red Woods",
  #        "author":"Red, Adam",
  #        "keywords":"blue, portrait"
  #       }
  #     ]
  #   }
  #   ```  
  #
  # @example_request
  #   ```json
  #   {
  #     "with": {
  #       "media_type":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with MediaTypes.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "media_type":"Image"
  #       },
  #       {
  #        "id":2,
  #        "media_type":"Audio"
  #       },
  #       {
  #        "id":3,
  #        "media_type":"Video"
  #       },
  #       {
  #        "id":4,
  #        "media_type":"Set"
  #       }
  #     ]
  #   }
  #   ```  
  #
  # @example_request
  #   ```json
  #   {
  #     "with": {
  #       "flags":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with flags.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "is_public":true,
  #        "is_private":false,
  #        "is_shared":false,
  #        "is_editable":true,
  #        "is_manageable":true,
  #        "is_favorite":false
  #       }
  #     ]
  #   }
  #   ```  
  # @example_request_description The responding MediaResource with id 1 is accesible by everyone and is editable, managable by the current user. The MediaResource is not part of the current user's favorites.
  #
  #
  # @example_request
  #   ```json
  #   {
  #     "with": {
  #       "children":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with children.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #        "id":1,
  #        "type":"media_entry"
  #       },{
  #         "id":2,
  #         "type":"media_set",
  #         "children": {
  #           "media_resources": {[
  #             {"id":123},{"id":1231},{"id":4123}
  #           ]},
  #           "pagination": {
  #             "total":3,
  #             "page":1,
  #             "per_page":36,
  #             "total_pages":1
  #           }
  #         }
  #       },
  #     ]
  #   }
  #   ```  
  # @example_request_description Children are not responding for MediaEntries. The children uses a "nested" pagination for its own. If you want to controll the pagination inside the children pass a "pagination" attribute to the children value (e.g. {"pagination":{"page":2}}). If you want to forward a "with" to the children to request more nested informations just parse a Hash to the value containing the with informations (e.g. {"with":{"children":{with:{"media_type": true}}}}).
  #
  # @example_request
  #   ```json
  #   {
  #     "with": {
  #       "parents":true
  #     }
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with parents.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #         "id":1,
  #         "type":"media_entry",
  #         "parents": {
  #           "media_resources": {[
  #             {"id":54}
  #           ]},
  #           "pagination": {
  #             "total":1,
  #             "page":1,
  #             "per_page":36,
  #             "total_pages":1
  #           }
  #         }
  #       },
  #       {
  #        "id":2,
  #        "type":"media_set",
  #        "parents": {
  #          "media_resources": {[
  #            {"id":62},{"id":151},{"id":941}
  #          ]},
  #          "pagination": {
  #            "total":3,
  #            "page":1,
  #            "per_page":36,
  #            "total_pages":1
  #          }
  #        }
  #       },
  #     ]
  #   }
  #   ```  
  # @example_request_description MediaEntries and MediaSets are responding with parents. The parents uses a "nested" pagination for its own. If you want to controll the pagination inside the parents pass a "pagination" attribute to the children value (e.g. {"pagination":{"page":2}}). If you want to forward a "with" to the parents to request more nested informations just parse a Hash to the value containing the with informations (e.g. {"with":{"parents":{"with":{"media_type": true}}}}).
  #
  def index(ids = (params[:collection_id] ? MediaResource.by_collection(current_user.id, params[:collection_id]) : params[:ids]),
            type = params[:type],
            with = params[:with] || {},
            top_level = params[:top_level],
            user = (params[:user_id] ? User.find(params[:user_id]) : nil),
            group = (params[:group_id] ? Group.find(params[:group_id]) : nil),
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
          when "author"
            resources = resources.ordered_by_author
          when "title"
            resources = resources.ordered_by_title
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

        resources = resources.accessible_by_group(group) if group
        
        resources = resources.by_user(user) if user
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

        render json: view_context.hash_for_media_resources_with_pagination(resources, true, with).to_json
      }
    end
  end

  def show
    redirect_to @media_resource
  end

  def edit
    render :template => "/#{@media_resource.type.pluralize.underscore}/edit"
  end

  def destroy
    @media_resource.destroy

    respond_to do |format|
      format.html { 
        flash[:notice] = "Der Inhalt wurde gelöscht."
        redirect_back_or_default(media_resources_path) 
      }
      format.json {
        render :json => {:id => @media_resource.id}
      }
    end
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
        render :json => view_context.json_for(child_resources, {:parents => true})
      }
    end
  end

###################################################################################

  ##
  # Get the image of MediaResource:
  # 
  # @resource /media_resources/:id/image
  #
  # @action GET
  # 
  # @required [Integer] id The id of the MediaResource you want to fetch the image for.
  # @optional [String] size Set the responding size of the image: "small"(100x100) | "small_125"(125x125) | "medium"(300x300) | "large"(620x500)[DEFAULT] | "x_large"(1024x768).
  #
  # @example_request /media_resource/3234/image
  # @example_request_description Request the image for MediaResource id 3234.
  # @example_response [BINARY]
  # @example_request_description Responding with the image of that MediaResource or an placeholder image if the application cannot provide an image for that media_type.
  #
  def image(size = (params[:size] || :large).to_sym)
    # TODO dry => Resource#thumb_base64 and Download audio/video
    media_file = @media_resource.get_media_file(current_user)
    
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

      unless params[:owner_id].blank? 
        resources = resources.where("user_id in (?) ", params[:owner_id].map(&:to_i))
      end

      unless params[:group_id].blank?
        resources = resources.where( %Q< media_resources.id  in (
          #{MediaResource
             .grouppermissions_not_disallowed(current_user, :view)
             .where("grouppermissions.group_id in ( ? )",params[:group_id].map(&:to_i))
             .select("media_resource_id").to_sql})>)
      end

      unless params[:permission_preset].blank? 
        presets = PermissionPreset.where(" id in ( ? )",  params[:permission_preset].map(&:to_i))
        resources = resources.where_permission_presets_and_user presets, current_user
      end

      resources = resources.paginate(:page => page, :per_page => per_page)

      respond_to do |format|
        format.json {
          render json: view_context.hash_for_media_resources_with_pagination(resources, true, with).to_json
        }
      end

    else

      @resources = resources.search(query)

      @owners = User.includes(:person)
        .where("users.id in (#{resources.search(query).select("media_resources.user_id").to_sql}) ")
        .order("people.lastname, people.firstname DESC")

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

