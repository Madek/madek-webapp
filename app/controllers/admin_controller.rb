class AdminController < ApplicationController
  layout 'admin'

  private

  def authenticated?
    raise AuthorizationError unless current_user
    raise ForbiddenError unless current_user.admin?
  end
end
