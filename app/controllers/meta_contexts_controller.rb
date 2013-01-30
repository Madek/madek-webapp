# -*- encoding : utf-8 -*-
class MetaContextsController < ApplicationController

  before_filter do
    unless (context_id = params[:id]).blank?
      @context = if (context_id.respond_to?(:is_integer?) and context_id.is_integer?)
        MetaContext.find(context_id)
      else
        MetaContext.send(context_id)
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
  # @optional [Hash] with[vocabulary] Adds Vocabulary to the responding MetaContext. 
  # @optional [Hash] with[abstract] Adds Abstract to the responding MetaContext. 
  #
  # @example_request /meta_contexts/upload.json
  # @example_request_description Request the "upload" MetaContext.
  # @example_response {"name": "upload", "label": "Upload", "description": "Context needed for fill in MetaData during upload."}
  #
  # @example_request {"name": "upload", "with": {"meta_keys": true}} 
  # @example_request_description Request the MetaContext "upload" with MetaKeys.
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
  def show(with = params[:with] || {})
    respond_to do |format|
      format.html {
        @resources_count = MediaResource.filter(current_user, {:meta_context_ids => [@context.id]}).count
        # @context_json = view_context.hash_for(@context, with.merge({vocabulary: true, abstract: true}))
        # @abstract_slider_hash = { :context_id => @context.id,
        #                           :total => @context.media_entries(current_user).to_a.size # OPTIMIZE @context.media_entries(current_user).count
        #                         }
      }
      format.json {
        render :json => view_context.json_for(@context, with)
      }
    end
  end

  def abstract(min = (params[:min] || 1).to_i)
    @abstract = @context.abstract(current_user, min)
    respond_to do |format|
      format.html
      format.json { render :json => view_context.hash_for(@abstract, {:label => true}) }
    end
  end

  def vocabulary
    used_meta_term_ids = @context.used_meta_term_ids(current_user)
    @vocabulary = view_context.vocabulary(@context, used_meta_term_ids)
    respond_to do |format|
      format.html
    end
  end

end
