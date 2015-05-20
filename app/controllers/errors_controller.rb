# This handles all errors/exceptions.

# What happens in Rails before get here:
# - Rails config: set the "expection handling rack app" to this controller,
#    see: <http://api.rubyonrails.org/classes/ActionDispatch/ShowExceptions.html>
# - If an exception happens from here on, a plain text fallback is used!
# - Very good overview: <http://blog.siami.fr/diving-in-rails-exceptions-handling>
class ErrorsController < ApplicationController

  skip_before_action :authenticate_user!

  def show
    exception = env['action_dispatch.exception']
    @get = Presenters::Errors::ErrorShow.new(exception)

    # select template (show server errors as plain page, client error in app)
    type = (@get.status_code < 500) ? 'client_error' : 'server_error'
    layout = (@get.status_code < 500) ? 'application' : '_base'

    # TODO: potentially refactor using respond_with
    respond_with(@get) do |format|
      format.html { render(type, layout: layout, status: @get.status_code) }
      format.json { render(plain: @get.dump.to_json, status: @get.status_code) }
    end
  end
end
