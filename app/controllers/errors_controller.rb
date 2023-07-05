# This handles all errors/exceptions.

# What happens in Rails before get here:
# - Rails config: set the "expection handling rack app" to this controller,
#    see: <http://api.rubyonrails.org/classes/ActionDispatch/ShowExceptions.html>
# - If an exception happens from here on, a plain text fallback is used!
# - Very good overview: <http://blog.siami.fr/diving-in-rails-exceptions-handling>

class ErrorsController < ApplicationController

  # skips the checks that raise errors that are handled here (or it loops!)
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_usage_terms_accepted!
  skip_before_action :verify_authenticity_token

  def show
    skip_authorization
    exception = request.env['action_dispatch.exception']
    for_url = request.original_fullpath
    err = Presenters::Errors::ErrorShow.new(exception, for_url: for_url, return_to: for_url)
    # Select type (show server errors as plain page, client error in app):
    type = (err.status_code < 500) ? 'client_error' : 'server_error'
    # keep flash around for next request
    flash.keep
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
    template = get_template(type, err.status_code)

    respond_to do |f|
      f.any do # html (for any requested format, prevents 500 UnknownFormat error for formats other than html, json, yaml)
        @get = err
        render(template, layout: layout, status: err.status_code, content_type: "text/html")
      end
      f.json { render(json: wrap_error(err), status: err.status_code) }
      f.yaml { render(plain: wrap_error(err).to_yaml, status: err.status_code) }
    end
  end

  def wrap_error(err)
    err = err.dump if err.dump
    Hash(error: err.to_h).as_json
  end

  def get_template(error_type, status_code)
    # use a partial named like the status code if it exists, or "default by type"
    template_by_status = "errors/_by_status/#{status_code}"
    if lookup_context.find_all(template_by_status).first.present?
      template_by_status
    else
      error_type
    end
  end
end
