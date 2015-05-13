# This handles all errors/execptions.

# What happens in Rails before get here:
# - Rails config: set the "expection handling rack app" to this controller,
#    see: <http://api.rubyonrails.org/classes/ActionDispatch/ShowExceptions.html>
# - If an exception happens from here on, a plain text fallback is used!
# - Very good overview: <http://blog.siami.fr/diving-in-rails-exceptions-handling>
class ErrorsController < ApplicationController

  skip_before_action :authenticate_user!

  def show
    # get the expection and corresponding status code and response from Rails:
    exception = env['action_dispatch.exception']
    # these fall back to 500/'Internal Server Error' if nothing is specified:
    status = ActionDispatch::ExceptionWrapper.new(Rails.env, exception).status_code
    message = ActionDispatch::ExceptionWrapper
                .rescue_responses[exception.class.name]
                .to_s.titleize # e.g.

    # get some details about the exception, with cleaned up backtrace paths:
    details = [exception.try(:message) || message, exception.try(:cause),
               exception.try(:backtrace).try(:first, 3)]
    details = clean_up_trace(details.flatten.uniq)

    render('errors', status: status, # <- sets HTTP status!
                     locals: { code: status, message: message, details: details })
  end

  private

  def clean_up_trace(lines)
    lines.map { |trace| trace.try(:remove, Regexp.new(Rails.root.to_s + '/')) }
  end
end
