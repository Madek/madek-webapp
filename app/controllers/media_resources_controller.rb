# -*- encoding : utf-8 -*-
class MediaResourcesController < ApplicationController

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
  # @example_request {"with": {"meta_data": {"meta_context_names": ["core"]}}} Requests MediaResources with all nested MetaData for the MetaContext with the name "core". 
  # @example_response {"media_resources:": [{"id":1, "meta_data": {"title": "My new Picture", "author": "Musterman, Max", "portrayed_object_dates": null, "keywords": "picture, portrait", "copryright_notice"}}, ...], "pagination": {"total": 100, "page": 1, "per_page": 36, "total_pages": 2}}
  #
  # @example_request {"ids": [1,2,3], "with": {"image": {"as": "base64"}}} Is requesting MediaResources with id 1,2 and 3. Adds an image as base64 to the respond.
  # @example_response {"media_resources:": [{"id":1, "image": ""data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/4gxYSUNDX1BST0ZJTEUAAQEAAAxITGlu bwIQAABtbnRyUkdCIFhZWiAHzgACAAkABgAxAABhY3NwTVNG"}, ...], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @example_request {"ids": [1,2,3], "with": {"filename": true}} Request MediaResources with filenames
  # @example_response {"media_resources:": [{"id":1, "filename": "my_file_name.jpg"}, {"id":2, "filename": "my_2_file_name.jpg"}, {"id":3, "filename": "my_3_file_name.jpg"}], "pagination": {"total": 3, "page": 1, "per_page": 36, "total_pages": 1}}
  #
  # @response_field [Integer] [].id The id of the MediaResource  
  # @response_field [Hash] [].meta_data The MetaData of the MediaResource (To get a list of possible MetaData - or the schema - you have to consider the MetaDatum resource)
  # @response_field [String] [].filename The Filename of a MediaEntry's MediaFile (in case of MediaSets its null) 
  #
  def index(ids = (params[:collection_id] ? MediaResource.by_collection(current_user.id, params[:collection_id]) : params[:ids]),
            page = params[:page],
            per_page = [(params[:per_page] || PER_PAGE.first).to_i, PER_PAGE.first].min)

    @media_resources = MediaResource.media_entries_or_media_entry_incompletes_or_media_sets.
                        accessible_by_user(current_user).
                        order("media_resources.updated_at DESC").
                        paginate(:page => page, :per_page => per_page)

    @media_resources = @media_resources.where(:id => ids) if ids
    
    respond_to do |format|
      format.json
    end
  end


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

end

