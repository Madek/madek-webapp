class AdminController < ApplicationController
  before_action :admin_user_authenticated?
  layout 'admin'

  private

  # TODO, this is wrong
  # unless user? => 401
  # unless admin? => 403
  def admin_user_authenticated?
    render 'public/401.html', status: 401, layout: false unless  current_user\
      and current_user.admin?
  end
end
