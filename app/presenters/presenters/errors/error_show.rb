module Presenters
  module Errors
    class ErrorShow < Presenter

      def initialize(exception, for_url:, return_to:)
        @exception = exception
        @error_class = exception.class.name
        @for_url = for_url
        @return_to = return_to
      end

      attr_reader :for_url, :return_to

      # get status code and corresponding message from Rails
      # (these fall back to 500/'Internal Server Error' if nothing is specified):
      def status_code
        @status_code ||= \
          ActionDispatch::ExceptionWrapper.new(Rails.env, @exception).status_code
      end

      def message
        ActionDispatch::ExceptionWrapper
          .rescue_responses[@error_class].to_s.titleize
      end

      # get some details about the exception, with cleaned up backtrace paths:
      def details
        details = ["#{@error_class}:\n#{@exception.try(:message)}"]
        # for server errors, also get backtrace
        if status_code >= 500
          details.push(
            @exception.try(:cause),
            @exception.try(:backtrace).try(:first, 3))
        end
        clean_up_trace(details.flatten.uniq)
      end

      # optional data attached to error class (can be a Presenter)

      def data
        @exception.class.data if @exception.class.respond_to?(:data)
      end

      private

      def clean_up_trace(lines)
        lines.map { |trace| trace.try(:remove, Regexp.new(Rails.root.to_s + '/')) }
      end
    end
  end
end
