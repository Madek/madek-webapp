module Presenters
  module Errors
    class ErrorShow < Presenter
      attr_reader :status_code, :message, :details

      def initialize(exception)
        error_class = exception.class.name

        # get status code and corresponding message from Rails
        # (these fall back to 500/'Internal Server Error' if nothing is specified):
        @status_code = ActionDispatch::ExceptionWrapper
                        .new(Rails.env, exception).status_code
        @message = ActionDispatch::ExceptionWrapper
                    .rescue_responses[error_class].to_s.titleize

        # get some details about the exception, with cleaned up backtrace paths:
        @details = ["#{error_class}:\n#{exception.try(:message)}",
                    exception.try(:cause),
                    exception.try(:backtrace).try(:first, 3)]
        @details = clean_up_trace(details.flatten.uniq)
      end

      private

      def clean_up_trace(lines)
        lines.map { |trace| trace.try(:remove, Regexp.new(Rails.root.to_s + '/')) }
      end
    end
  end
end
