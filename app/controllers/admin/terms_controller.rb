# -*- encoding : utf-8 -*-
class Admin::TermsController < Admin::AdminController # TODO rename to Admin::MetaTermsController ??

  before_filter :pre_load

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
    redirect_to admin_terms_path
  end

  def destroy
    @term.destroy unless @term.is_used?
    redirect_to admin_terms_path
  end

#####################################################

  private

  def pre_load
    unless (params[:term_id] ||= params[:id]).blank?
      @term = MetaTerm.find(params[:term_id])
    end
  end

end
