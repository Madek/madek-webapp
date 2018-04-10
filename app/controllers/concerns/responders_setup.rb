module Concerns
  module RespondersSetup
    extend ActiveSupport::Concern

    included do
      self.responder = ApplicationResponder
      respond_to :html, :json, :yaml # TODO: is this safe for all controllers?

      def respond_with_custom(resource, location: nil, **options)
        respond_to do |f|
          f.html do
            # "unwrap" resource from presenter for responders:
            if resource.is_a?(Presenters::Shared::AppResource)
              resource = resource.instance_variable_get('@app_resource')
            end
            respond_with_default(resource, location: location, **options)
          end
          f.json { respond_with_default(resource, **options) }
          f.yaml { respond_with_default(resource, **options) }
        end
      end
      alias_method :respond_with_default, :respond_with
      alias_method :respond_with, :respond_with_custom
    end
  end
end
