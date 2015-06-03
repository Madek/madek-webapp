class AdminController < ApplicationController
  layout 'admin'

  rescue_from ActiveRecord::ActiveRecordError,
              with: :render_error

  before_action do
    authorize :admin, :logged_in_and_admin?
  end

  before_action :set_alerts

  private

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

  def reraise_according_to_login_state
    if current_user
      raise Errors::ForbiddenError, 'Admin access denied!'
    else
      raise Errors::UnauthorizedError
    end
  end
end
