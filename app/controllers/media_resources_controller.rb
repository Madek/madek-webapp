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
        @media_resource = if params[:collection_id]
          MediaResource.accessible_by_user(current_user, action).by_collection(params[:collection_id])
        else
          MediaResource.accessible_by_user(current_user, action).find(params[:media_resource_id])
        end
      end
    rescue
      not_authorized!
    end
  end

###################################################################################

  ##
  # Get a list of MediaResources
  # 
  # @resource /media_resources
  #
  # @action GET
  # 
  # @optional [String] sort Sort the response (DESC) by: "updated_at"(Default) | "created_at".
  #
  # @optional [Array] ids A collection of MediaResources you want to fetch informations for.
  # @optional [String] type Filter the response by MediaResource types: "media_sets" | "media_entries".
  # @optional [String] search Make a search request which searches in all MetaData of all MediaResources responding with matched MediaResources.
  # @optional [String] accessible_action Narrow down the result of MediaResources to the defined accessible_action ("view" | "edit" | "manage" | "download")
  # @optional [Boolean] favorites Lists the favorites only.
  #
  # @optional [String] with_filter Request the possible filters data that can be applied for the filtered MediaResources: "false"(Default) | "true" | "only".
  # @optional [Array] meta_data[>>type<<][ids] Filter the responding MediaResources by applying one or multiple ids of a specific type of MetaData (intersection of multiple filters and ids).
  # @optional [Array] permissions[preset|owner|group][ids] Filter the responding MediaResources by applying one or multiple ids of a specific type of Permissions (union of multiple filters and ids).
  #
  # @optional [Hash] with[meta_data] Adds MetaData to the responding collection of MediaResources and forwards the hash as options to the MetaData.
  # @optional [Array] with[meta_data][meta_context_names] Adds all requested MetaContexts in the format: ["context_name1", "context_name2", ...] as MetaData to the responding MediaResources. 
  # @optional [Array] with[meta_data][meta_key_names] Adds all requested MetaKeys in the format: ["key_name1", "key_name2", ...] as MetaData to the responding MediaResources. 
  # @optional [Hash] with[image] Request the image of the MediaResources. You can define the responding image format like {"image": {"as": "base64" | "url"}}. The image size can be requested with {"image": {"size": "small"(100x100) | "small_125"(125x125) | "medium"(300x300) | "large"(620x500) | "x_large"(1024x768) }}
  # @optional [Boolean] with[filename] Request the filename of the MediaResources.
  # @optional [Boolean] with[media_type] Request the media_type of the MediaResources.
  # @optional [Boolean] with[size] Request the size of the MediaFile of a particular MediaEntry.
  # @optional [Hash|Boolean] with[children] Request the children of the responding MediaResources (Attention: they are paginated!). Option forwarding possible.
  # @optional [Array] with[children][with] Forward with conditions to the children.
  # @optional [Hash|Boolean] with[parents] Request the parents of the responding MediaResources (Attention: they are paginated!). Option forwarding possible.
  # @optional [Array] with[parents][with] Forward with conditions to the parents.
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
  # @response_field [Boolean] is_favorite The is_favorite status.
  # @response_field [Integer] size The size of the MediaFile of a particular MediaEntry.
  # @response_field [Array] children The children of a MediaResource (only for MediaSets)..
  # @response_field [Array] parents The parents of a MediaResource.
  # @response_field [Array] filter The filter that are applicable for the list of responding MediaResources.
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
  # @example_response_description Responding with the index of media resources. Default sorting is on the update_at attribute latest first. You get 36 elements per page and informations about the current pagination.
  #
  #####
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
  # @example_response_description
  #
  #####
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
  #####
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
  # @example_response_description
  #
  #####
  #
  # @example_request
  #   ```json
  #   {
  #     "ids": [1]
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
  # @example_response_description
  #
  #####
  #
  # @example_request
  #   ```json
  #   {
  #     "ids": [1]
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
  # @example_response_description
  #
  #####
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
  # @example_response_description
  #
  #####
  #
  # @example_request
  #   ```json
  #     "type":"media_sets"
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
  # @example_response_description
  #
  #####
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
  # @example_response_description
  #
  #####
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
  # @example_response_description
  #
  #####
  #
  # @example_request
  #   ```json
  #   {
  #     "search":"blue"
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
  # @example_response_description
  #
  #####
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
  # @example_response_description
  #
  #####
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
  # @example_response_description Children are not responding for MediaEntries. The children uses a "nested" pagination for its own. If you want to controll the pagination inside the children pass a "pagination" attribute to the children value (e.g. {"pagination":{"page":2}}). If you want to forward a "with" to the children to request more nested informations just parse a Hash to the value containing the with informations (e.g. {"with":{"children":{with:{"media_type": true}}}}).
  #
  #####
  #
  # @example_request
  #   ```json
  #   {
  #     "ids": [1]
  #     "with": {
  #       "children":{
  #         "pagination": {
  #           page: 2,
  #           per_page: 2
  #         }
  #       }
  #     }
  #   }
  #   ``` 
  # @example_request_description Paginate through children of MediaResource with id 1.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #         "id":1,
  #         "type":"media_set",
  #         "children": {
  #           "media_resources": {[
  #             {"id":4123}
  #           ]},
  #           "pagination": {
  #             "total":3,
  #             "page":2,
  #             "per_page":2,
  #             "total_pages":2
  #           }
  #         }
  #       },
  #     ]
  #   }
  #   ```  
  # @example_response_description 
  #
  #####
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
  # @example_response_description MediaEntries and MediaSets are responding with parents. The parents uses a "nested" pagination for its own. If you want to controll the pagination inside the parents pass a "pagination" attribute to the children value (e.g. {"pagination":{"page":2}}). If you want to forward a "with" to the parents to request more nested informations just parse a Hash to the value containing the with informations (e.g. {"with":{"parents":{"with":{"media_type": true}}}}).
  #
  #####
  #
  # @example_request
  #   ```json
  #   {
  #     "with_filter": true;
  #   }
  #   ``` 
  # @example_request_description Request MediaResources with applicable filters.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": "[...]"
  #     "filter": [
  #       {
  #         context_name: "media_content",
  #         context_label: "Werk",
  #         filter_type: "meta_data",
  #         keys: [
  #           {
  #             key_name: "keywords",
  #             key_label: "Keywords for content and design",
  #             terms: [
  #               {
  #                 id: 4359,
  #                 value: "blueprint",
  #                 count: 1
  #               }, {
  #                 id: 4811,
  #                 value: "world",
  #                 count: 2
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ] 
  #   }
  #   ```  
  # @example_response_description The responding MediaResources can be filtered by "keywords". Two Keywords ("blueprint", "world") are applicable as filter for the current list of MediaResources.
  #
  #####
  #
  # @example_request
  #   ```json
  #   {
  #     "meta_data": {
  #       "keywords": {
  #         "ids": [4359]
  #       }
  #     },
  #     "with": {"meta_data": {"meta_key_names": ["keywords"]}}
  #   }
  #   ``` 
  # @example_request_description Request MediaResources and apply a MetaData filter for the MetaDatumType "keywords" by id 4359.
  # @example_response
  #   ```json
  #   {
  #     "media_resources": [
  #       {
  #         "id": 8183,
  #         "type": "media_entry",
  #         "meta_data": [
  #           {
  #             "name": "keywords",
  #             "value": "architect; blueprint; building;",
  #             "raw_value": [
  #               {
  #                 "id": 2132,
  #                 "label": "architect"
  #               },{
  #                 "id": 4359,
  #                 "label": "blueprint"
  #               },{
  #                 "id": 51232,
  #                 "label": "building"
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #   }
  #   ```  
  # @example_response_description The responding MediaResources are filtered by "keywords": "blueprint". So the results are containing that MetaData.
  #
  def index(with_filter = params[:with_filter],
            with = params[:with] || {},
            sort = params[:sort],
            page = params[:page],
            per_page = [(params[:per_page] || PER_PAGE.first).to_i.abs, PER_PAGE.last].min)

    @filter = MediaResource.get_filter_params params

    respond_to do |format|
      format.html { @media_resources_count = MediaResource.accessible_by_user(current_user).count }
      format.json {
        resources = MediaResource.filter(current_user, @filter).ordered_by(sort)

        h = case with_filter

            when "true"
              view_context.hash_for_media_resources_with_pagination(resources, \
                      {:page => page, :per_page => per_page}, with, false) \
                      .merge({:filter => view_context.hash_for_filter(resources)})

            when "only"
            {:filter => view_context.hash_for_filter(resources)}
          
            else
              view_context.hash_for_media_resources_with_pagination(resources, \
                {:page => page, :per_page => per_page}, with, false)

          end

        render json: h.merge(:current_filter => @filter).to_json
      }
    end
  end

  def show
    redirect_to @media_resource
  end

  def browse
    @browsable_meta_terms = []
    @media_resource.meta_data.for_meta_terms.each do |meta_datum|
      meta_datum.value.each do |meta_term|
        count = MediaResource.filter(current_user, {:meta_data => {meta_datum.meta_key.label.to_sym => {:ids => [meta_term.id]}}}).where("media_resources.id != ?", @media_resource.id).count
        if count > 0
          @browsable_meta_terms.push :meta_term => meta_term, :meta_datum => meta_datum, :count => count
        end
      end
    end
  end

  def edit
    @contexts = if @media_resource.is_a? MediaEntry
      @contexts = MetaContext.defaults + @media_resource.individual_contexts
    elsif @media_resource.is_a? MediaSet
      @contexts = [MetaContext.media_set]
    end

    @meta_data = {}
    @contexts.each {|context| @meta_data[context.id] = @media_resource.meta_data.for_context(context) }
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

  def collection(ids = params[:ids] || raise("ids are required"),
                 relation = params[:relation],
                 collection_id = params[:collection_id])
    if request.post? and ids
      ids = case relation
        when "parents"
          MediaResource.where(:id => ids).flat_map do |child|
            child.parent_sets.accessible_by_user(current_user).pluck("media_resources.id")
          end.uniq
        else
          ids
      end

      collection = Collection.add ids, collection_id
    end

    respond_to do |format|
      format.json { render json: {collection_id: collection[:id]} }
    end
  end

###################################################################################

  def toggle_favorites
    current_user.favorites.toggle(@media_resource)
    respond_to do |format|
      format.js { render :partial => "favorite_link", :locals => {:media_resource => @media_resource} }
    end
  end

  def favor
    current_user.favorites.favor(@media_resource)
    respond_to do |format|
      format.json { render :nothing => true, :status => :no_content }
    end
  end

  def disfavor
    current_user.favorites.disfavor(@media_resource)
    respond_to do |format|
      format.json { render :nothing => true, :status => :no_content }
    end
  end

###################################################################################
  
  ##
  # Manage parent media sets from a specific media set.
  # 
  # @url [POST] /media_sets/parents?[arguments]
  # @url [DELETE] /media_sets/parents?[arguments]
  # 
  # @argument [parent_media_set_ids] array The ids of the parent media sets to remove/add
  #
  # @example_request
  #   {"parent_media_set_ids": [1,2,3], "media_set_ids": [5]}
  #   {"parent_media_set_ids": [1,2,3], "media_set_ids": [5,6]}
  #
  # @request_field [Array] parent_media_set_ids The ids of the parent media sets to remove/add  
  # @request_field [Array] media_set_ids The ids of the media sets that have to be added to the parent sets (given in "parent_media_set_ids")   
  #
  # @example_response
  #   [{"id":407, "parent_ids":[1,2,3]}]
  # 
  # @response_field [Hash] media_set The media set changed
  # @response_field [Integer] media_set.id The id of the changed media set
  # @response_field [Array] media_set.parent_ids The ids of the parents of the changes media set 
  # 
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
  # Get the image of a MediaResource:
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
    if size == :maximum and not current_user.authorized? :download, @media_resource
      size = :x_large
    end

    # TODO dry => Resource#thumb_base64 and Download audio/video
    media_file = @media_resource.get_media_file(current_user)

    if (not media_file) and @media_resource.is_a? MediaSet
      # empty gif pixel
      output = "R0lGODlhAQABAIAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==\n"
      send_data Base64.decode64(output), :type => "image/gif", :disposition => 'inline'
    else
      preview = media_file.get_preview(size)
      if preview and File.exist?(file = File.join(THUMBNAIL_STORAGE_DIR, media_file.shard, preview.filename))
        output = File.read(file)
        send_data output, :type => preview.content_type, :disposition => 'inline'
      else
        output = media_file.thumb_placeholder(size)
        send_data output, :type => "image/png", :disposition => 'inline'
      end
    end
  end  

end

