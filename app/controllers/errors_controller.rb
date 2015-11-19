# This handles all errors/exceptions.

# What happens in Rails before get here:
# - Rails config: set the "expection handling rack app" to this controller,
#    see: <http://api.rubyonrails.org/classes/ActionDispatch/ShowExceptions.html>
# - If an exception happens from here on, a plain text fallback is used!
# - Very good overview: <http://blog.siami.fr/diving-in-rails-exceptions-handling>

class ErrorsController < ApplicationController

  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def show
    exception = env['action_dispatch.exception']
    err = Presenters::Errors::ErrorShow.new(exception)
    # Select type (show server errors as plain page, client error in app):
    type = (err.status_code < 500) ? 'client_error' : 'server_error'
    respond_with_error(err, type)
  end

  def proxy_error
    # Only shown on localhost, rendered once per deploy as a static page for proxy.
    err = Pojo.new(
      status_code: 502,
      message: 'Bad Gateway',
      details: ['Application down!']
    )
    respond_with_error(err, 'server_error')
  end

  private

  def respond_with_error(err, type)
    # NOTE: it is important to use the base layout for server errors,
    # because when something is broken we don't want to hit the db, etc.
    layout = (type == 'server_error') ? '_base' : 'application'
    respond_to do |f|
      f.html do
        @get = err
        render(type, layout: layout, status: err.status_code)
      end
      f.json { render(json: wrap_error(err), status: err.status_code) }
      f.yaml { render(plain: wrap_error(err).to_yaml, status: err.status_code) }
    end
  end

  def wrap_error(err)
    err = err.dump if err.dump
    excluded = :details if err[:status_code] < 500
    Hash(error: err.except(excluded).to_h).as_json
  end
end
