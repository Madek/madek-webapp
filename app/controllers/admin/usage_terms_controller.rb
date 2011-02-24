# -*- encoding : utf-8 -*-
class Admin::UsageTermsController < Admin::AdminController

  before_filter :pre_load

  def show
  end

  def edit
  end

  def update
    @usage_term.update_attributes(params[:usage_term])
    current_user.usage_terms_accepted!
    redirect_to :action => :show
  end


#####################################################

  private

  def pre_load
      @usage_term = UsageTerm.current
  end

end
