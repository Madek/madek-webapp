module Concerns
  module RespondersSetup
    extend ActiveSupport::Concern

    included do
      self.responder = ApplicationResponder
      respond_to :html, :json, :yaml # TODO: is this safe for all controllers?

      def respond_with_custom(resource, location: nil, **options)
        respond_to do |f|
          f.json { respond_with_default(resource, **options) }
          f.yaml { respond_with_default(resource, **options) }
          f.html { respond_with_default(resource, location: location, **options) }
        end
      end
      alias_method :respond_with_default, :respond_with
      alias_method :respond_with, :respond_with_custom
    end
  end
end
