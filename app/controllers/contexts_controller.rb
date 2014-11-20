# -*- encoding : utf-8 -*-
class ContextsController < ApplicationController

  def initialize_for_view
    if (params[:id]).blank?
      raise "No context.id given!"
    end
    @context = Context.find(params[:id])

    @entries = ::Vocabulary.media_entries @context, @current_user
    @entries_count = ::Vocabulary.media_entries_count @context, @current_user
    
    # TODO: queries
    @entries_with_terms_count = 2342
    @entries_with_terms_count
    @entries_total_count = 1337
  end

  def show
    initialize_for_view
    @vocabulary = ::Vocabulary.build_for_context_and_user(@context, @current_user)
    @max_usage_count = @vocabulary.map{|key|
      # guard against empty keys
      key[:meta_terms].empty? ? 0 : key[:meta_terms].map{|term|term[:usage_count]}.max
    }.max
  end

  def entries
    initialize_for_view
  end

end
