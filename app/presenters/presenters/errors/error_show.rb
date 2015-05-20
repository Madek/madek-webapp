module Presenters
  module Errors
    class ErrorShow < Presenter
      attr_reader :status_code, :message, :details

      def initialize(exception)
        # get the expection and corresponding status code and response from Rails:
        @status_code = \
          ActionDispatch::ExceptionWrapper.new(Rails.env, exception).status_code
        # these fall back to 500/'Internal Server Error' if nothing is specified:
        status_message = ActionDispatch::ExceptionWrapper
          .rescue_responses[exception.class.name]
          .to_s.titleize # e.g.

        # get some details about the exception, with cleaned up backtrace paths:
        @message = exception.try(:message) || status_message
        @details = [@message,
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
