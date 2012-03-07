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
  # @example_request {"with": {"meta_data": {"meta_contexts": [{name: "core"}]}}} Requests MediaResources with all nested MetaData for the MetaContext with the name "core". 
  # @example_response [{"id": 1, "meta_data": {"title": "Landscape Visualization", "author": "Musterman, Max", "portrayed_object_dates": "2010", "keywords": "Landscapes, Visualization", "copyright_notice": "Max Mustermann has copyright", "uploaded_by": "Musterman, Max", "uploaded_at": "2010-04-28 12:00:29 +0200"}}, ...]
  #
  # @response_field [Integer] [].id The id of the MediaResource  
  #
  # @response_field [Hash] [].meta_data The MetaData of the MediaResource  
  # @response_field [String] [].meta_data.title The title of the MediaResource
  # @response_field [String] [].meta_data.author The author of the MediaResource
  # @response_field [String] [].meta_data.portrayed_object_dates The dates for the portrayed object
  # @response_field [String] [].meta_data.keywords The keywords for the MediaResource
  # @response_field [String] [].meta_data.copyright_notice The copyright_notice for the MediaResource
  # @response_field [String] [].meta_data.uploaded_by The name of the uploader of the MediaResource
  # @response_field [String] [].meta_data.uploaded_at The date when the MediaResource was uploaded
  #
  def index(ids = params[:ids])
    @media_resources = MediaResource.media_entries_and_media_sets.accessible_by_user(current_user).order("media_resources.updated_at DESC")
    @media_resources = @media_resources.find(ids) if ids
    
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

end

