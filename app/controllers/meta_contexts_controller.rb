# -*- encoding : utf-8 -*-
class MetaContextsController < ApplicationController

  before_filter :pre_load

  def show
    @vocabulary_json = @context.vocabulary(current_user).as_json
    @abstract_json = @context.abstract(current_user).as_json
    @abstract_slider_json = { :context_id => @context.id,
                              :total_entries => begin
                                                  # OPTIMIZE @context.media_entries(current_user).count
                                                  me = @context.media_entries(current_user)
                                                  me.to_a.size
                                                end
                            }.as_json
  end

  def abstract
    @abstract_json = @context.abstract(current_user, params[:value].to_i).as_json
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

#################################################################

  private

  def pre_load
    params[:context_id] ||= params[:id]
    @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
  end

end
