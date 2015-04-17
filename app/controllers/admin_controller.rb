class AdminController < ApplicationController
  responders :flash
  respond_to :html
  layout 'admin'

  rescue_from ActiveRecord::ActiveRecordError,
              with: :render_error
  rescue_from Pundit::NotAuthorizedError,
              with: :error_according_to_login_state

  before_action do
    authorize :admin, :logged_in_and_admin?
  end

  include Concerns::Admin::ActionMethods
  before_action :forget_vocabulary_url_params_if_requested

  private

  def render_error(error)
    @error = error
    wrapper = ActionDispatch::ExceptionWrapper.new(Rails.env, @error)
    @status_code = wrapper.status_code
    render "/admin/errors/#{@status_code}", status: @status_code
  end

  def error_according_to_login_state
      if current_user
        raise Errors::ForbiddenError, 'Admin access denied!'
      else
        raise Errors::UnauthorizedError, 'Please log in!'
      end
  end

  def forget_vocabulary_url_params_if_requested
    if params[:reset_vocabulary_params]
      vocabulary_url_params.each do |key|
        session[key] = nil
      end
    end
  end

  def remember_vocabulary_url_params
    vocabulary_url_params.each do |key|
      session[key] = params[key] if params[key].present?
    end
  end

  def vocabulary_url_params
    %i(
      vocabulary_id
      permission_id
      is_persisted
    )
  end
end
