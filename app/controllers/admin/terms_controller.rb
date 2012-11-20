# -*- encoding : utf-8 -*-
class Admin::TermsController < Admin::AdminController # TODO rename to Admin::MetaTermsController ??
  respond_to 'json'

  before_filter do
    unless (params[:term_id] ||= params[:id]).blank?
      @term = MetaTerm.find(params[:term_id])
    end
  end

#####################################################

  def index
    @terms = MetaTerm.order(LANGUAGES.first)
  end

  def new
    @term = MetaTerm.new
    respond_to do |format|
      format.js
    end
  end

  def create
    MetaTerm.create(params[:meta_term])
    redirect_to admin_terms_path    
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @term.update_attributes(params[:meta_term])

    respond_to do |format|
      format.js { render partial: "show", locals: {term: @term} }
    end
  end

  def destroy
    @term.destroy unless @term.is_used?
    redirect_to admin_terms_path
  end

######

  def meta_data_transfer_form
    render layout: false
  end
  
  def meta_data_transfer
    meta_term_originator= MetaTerm.find(params[:term_id])
    meta_term_receiver= MetaTerm.find(params[:id_receiver])
    
    ActiveRecord::Base.transaction do
      meta_term_receiver.meta_data << meta_term_originator.meta_data
      meta_term_originator.meta_data.destroy_all
    end

    redirect_to admin_terms_path
  end

######

  def keywords_transfer_form
    render layout: false
  end
  
  def keywords_transfer
    meta_term_originator= MetaTerm.find(params[:term_id])
    meta_term_receiver= MetaTerm.find(params[:id_receiver])
    
    ActiveRecord::Base.transaction do
      meta_term_receiver.keywords << meta_term_originator.keywords
    end

    redirect_to admin_terms_path
  end

###### 
  
  def data
    @terms = MetaTerm.limit 10
    respond_to do |format|
      format.json do
        render json: MetaTermsDatatable.new(view_context)
      end
    end
  end

end

