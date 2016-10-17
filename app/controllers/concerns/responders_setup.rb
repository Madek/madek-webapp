module Concerns
  module RespondersSetup
    extend ActiveSupport::Concern

    included do
      self.responder = ApplicationResponder
      respond_to :html, :json, :yaml # TODO: is this safe for all controllers?
      # fails *before* running (side-effects in) the controller, not after!
      # before_action :verify_requested_format!

      def respond_with_custom(resource, location: nil, **options, &block)
        respond_to do |f|
          f.json { respond_with_default(resource, **options) }
          f.yaml { respond_with_default(resource, **options) }
          f.html do
            # "unwrap" resource from presenter for responders:
            if resource.is_a?(Presenters::Shared::AppResource)
              resource = resource.instance_variable_get('@app_resource')
            end
            # NOTE: need to pass through block!
            respond_with_default(resource, location: location, **options, &block)
          end
        end
      end
      alias_method :respond_with_default, :respond_with
      alias_method :respond_with, :respond_with_custom
    end
  end
end
