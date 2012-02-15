# -*- encoding : utf-8 -*-
class Admin::UsageTermsController < Admin::AdminController

  before_filter do
    @usage_term = UsageTerm.current
  end

#####################################################

  def show
  end

  def edit
  end

  def update
    @usage_term.update_attributes(params[:usage_term])
    current_user.usage_terms_accepted!
    redirect_to :action => :show
  end

end
