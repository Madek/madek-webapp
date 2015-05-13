class AdminController < ApplicationController
  layout 'admin'

  rescue_from ActiveRecord::ActiveRecordError,
              with: :render_error

  before_action :authenticate_admin_user!
  before_action :set_alerts

  private

  def authenticate_admin_user!
    unless current_user.admin?
      raise Errors::ForbiddenError, 'Admin access denied!'
    end
  end

  def render_error(error)
    @error = error
    wrapper = ActionDispatch::ExceptionWrapper.new(Rails.env, @error)
    @status_code = wrapper.status_code
    render "/admin/errors/#{@status_code}", status: @status_code
  end

  def set_alerts
    @alerts ||= { error: (flash[:error] || []),
                  info: (flash[:info] || []),
                  success: (flash[:success] || []),
                  warning: (flash[:warning] || []) }
  end
end
