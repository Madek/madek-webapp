# This handles all errors/exceptions.

# What happens in Rails before get here:
# - Rails config: set the "expection handling rack app" to this controller,
#    see: <http://api.rubyonrails.org/classes/ActionDispatch/ShowExceptions.html>
# - If an exception happens from here on, a plain text fallback is used!
# - Very good overview: <http://blog.siami.fr/diving-in-rails-exceptions-handling>

# TODO: cleanup `responder` handling
class ErrorsController < ApplicationController

  skip_before_action :authenticate_user!

  def show
    exception = env['action_dispatch.exception']
    @get = Presenters::Errors::ErrorShow.new(exception)

    # Select template (show server errors as plain page, client error in app):
    type, layout = \
    if (@get.status_code < 500) then ['client_error', 'application']
    else
      # NOTE: it is important to use the base layout for server errors,
      # because when something is broken we don't want to hit the db, etc.
      ['server_error', '_base']
    end

    # NOTE: it's very important to set the `status` here because default is 200…
    respond_with(@get) do |format|
      format.html { render(type, layout: layout, status: @get.status_code) }
      format.json \
        { render(plain: wrap_error(@get).to_json, status: @get.status_code) }
      format.json \
        { render(plain: wrap_error(@get).to_yaml, status: @get.status_code) }
    end
  end

  def proxy_error
    # Only shown on localhost, rendered once per deploy as a static page for proxy.
    @get = OpenStruct.new(
      status_code: 502,
      message: 'Bad Gateway',
      details: ['Application down']
    )
    respond_with(@get) do |format|
      format.html \
        { render('server_error', layout: '_base', status: @get.status_code) }
      format.json \
        { render(plain: wrap_error(@get).to_json, status: @get.status_code) }
      format.yaml \
        { render(plain: wrap_error(@get).to_yaml, status: @get.status_code) }
    end
  end

  private

  def wrap_error(presenter)
    Hash(error: presenter.dump.to_h)
  end
end
