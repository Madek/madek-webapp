# -*- encoding : utf-8 -*-
class MetaContextsController < ApplicationController

  def initialize_for_view
    if (params[:id]).blank?
      raise "No context.id given!"
    end
    @context = MetaContext.find(params[:id])

    @entries = @context.media_entries @current_user
    @entries_count = @context.media_entries_count @current_user
    
    # TODO: queries
    @entries_with_terms_count = 2342
    @entries_with_terms_count
    @entries_total_count = 1337
  end

  def show
    initialize_for_view
    @vocabulary = @context.build_vocabulary @current_user
    # binding.pry
    @max_usage_count = @vocabulary.map{|key|
      # guard against empty keys
      key[:meta_terms].empty? ? 0 : key[:meta_terms].map{|term|term[:usage_count]}.max
    }.max
  end

  def entries
    initialize_for_view
  end

end
