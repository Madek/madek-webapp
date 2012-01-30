# -*- encoding : utf-8 -*-
class Admin::KeysController < Admin::AdminController # TODO rename to Admin::MetaKeysController ??

  before_filter :pre_load

  def index
    @keys = MetaKey.order(:label)
  end

  def new
    @key = MetaKey.new
    respond_to do |format|
      format.js
    end
  end

  def create
    MetaKey.create(params[:meta_key])
    redirect_to admin_keys_path    
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    meta_terms_attributes = params[:meta_key].delete(:meta_terms_attributes)

    params[:reassign_term_id].each_pair do |k, v|
      next if v.blank?
      from = @key.meta_terms.find(k)
      to = @key.meta_terms.find(v)
      next if from == to
      from.reassign_meta_data_to_term(to, @key)
      meta_terms_attributes.values.detect{|x| x[:id].to_i == from.id}[:_destroy] = 1
    end if params[:reassign_term_id]

    if params[:term_positions]
      positions = CGI.parse(params[:term_positions])["position[]"]
      positions.each_with_index do |id, i|
        # meta_terms_attributes.values.detect{|x| x[:id].to_i == id.to_i}[:position] = i+1
        @key.meta_key_meta_terms.where(:meta_term_id => id).first.update_attributes(:position => i+1)
      end
    end

    meta_terms_attributes.each_value do |h|
      if h[:id].nil? and LANGUAGES.any? {|l| not h[l].blank? }
        term = MetaTerm.find_or_create_by_en_GB_and_de_CH(h)
        @key.meta_terms << term
        #old??# h[:id] = term.id
      elsif h[:_destroy].to_i == 1
        term = @key.meta_terms.find(h[:id])
        @key.meta_terms.delete(term)
      end
    end if meta_terms_attributes
 
    @key.update_attributes(params[:meta_key])
    redirect_to admin_keys_path
  end

  def destroy
    @key.destroy if @key.meta_key_definitions.empty?
    redirect_to admin_keys_path
  end

#####################################################

  def mapping
    @graph = MetaKeyDefinition.keymapping_graph
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

#####################################################

  private

  def pre_load
      params[:key_id] ||= params[:id]
      @key = MetaKey.find(params[:key_id]) unless params[:key_id].blank?
  end

end
