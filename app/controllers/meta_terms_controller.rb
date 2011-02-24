# -*- encoding : utf-8 -*-
class MetaTermsController < ApplicationController
 
  # TODO only for extensible lists 
  def create
    term ||= begin
      h = {}
      LANGUAGES.each do |lang|
        h[lang] = params[:new_term]
      end
      Meta::Term.find_or_create_by_en_GB_and_de_CH(h)
    end
    meta_key = MetaKey.find(params[:meta_key_id])
    meta_key.meta_terms << term unless meta_key.meta_terms.include?(term) 

    respond_to do |format|
      format.js { render :json => {:id => term.id, :value => term.to_s} }
    end
  end
  
end
