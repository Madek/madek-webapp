# -*- encoding : utf-8 -*-
class MetaContextsController < ApplicationController

  before_filter do
    unless (context_id = params[:id]).blank?
      @context = if (context_id.respond_to?(:is_integer?) and context_id.is_integer?)
        MetaContext.find(context_id)
      else
        MetaContext.find_by_name(context_id)
      end
    end
  end

#################################################################


  ##
  # Get a MetaContext
  # 
  # @resource /meta_contexts/name.json
  #
  # @action GET
  # 
  # @required [String] name The name of the MetaContext you want to fetch informations for.
  #
  # @optional [Hash] with[keys] Adds MetaKeys to the responding MetaContext. 
  #
  # @example_request {} Request the "upload" MetaContext (/meta_contexts/upload.json)
  # @example_response {"name": "upload", "label": "Upload", "description": "Context needed for fill in MetaData during upload."}
  #
  # @example_request {"name": "upload", "with": {"meta_keys": true}} Request the MetaContext "upload" with MetaKeys.
  # @example_response {"name": "upload", "label": "Upload", "description": "Context needed for fill in MetaData during upload." "meta_keys":[{"name": "title", "position": 1, "settings": {"is_required":true, "min_length": 0, "max_length": 255}, "label": "Title", "hint": null, "description": "The title of the media entry"},...]}
  #
  # @response_field [String] name The name of the MetaContext.
  # @response_field [String] label The label of the MetaContext.
  # @response_field [String] description The description of the MetaContext.
  # @response_field [Array] meta_keys A collection of MetaKeys of the requested MetaContext.
  # @response_field [String] meta_keys[].name The name of the MetaKey.   
  # @response_field [String] meta_keys[].position The position of the MetaKey.   
  # @response_field [String] meta_keys[].label The label of the MetaKey.   
  # @response_field [String] meta_keys[].hint A hint for set a MetaKey.   
  # @response_field [String] meta_keys[].description A description of a MetaKey.
  # @response_field [String] meta_keys[].settings Otional settings of the MetaKey.
  #
  def show
    respond_to do |format|
      format.html {
        @vocabulary_json = @context.vocabulary(current_user).as_json
        @abstract_json = @context.abstract(current_user).as_json
        @abstract_slider_json = { :context_id => @context.id,
                                  :total_entries => begin
                                                      # OPTIMIZE @context.media_entries(current_user).count
                                                      me = @context.media_entries(current_user)
                                                      me.to_a.size
                                                    end
                                }.as_json
      }
      format.json {
        render @context
      }
    end
  end

  def abstract
    @abstract_json = @context.abstract(current_user, params[:value].to_i).as_json
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
