# -*- encoding : utf-8 -*-
class MetaContextsController < ApplicationController

  before_filter do
    unless (context_id = params[:id]).blank?
      @context = MetaContext.find(context_id)
    end
  end

#################################################################


  def show(with = params[:with] || {}) respond_to do |format|
      format.html {
        @resources_count = MediaResource.filter(current_user, {:meta_context_names => [@context.name]}).count
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
