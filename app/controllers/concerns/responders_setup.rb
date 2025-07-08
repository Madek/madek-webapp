module RespondersSetup
  extend ActiveSupport::Concern

  included do
    self.responder = ApplicationResponder
    respond_to :html, :json, :yaml

    def respond_with_custom(resource, location: nil, **options)
      respond_to do |f|
        f.html do
          # "unwrap" resource from presenter for responders:
          unwrapped_resource = if resource.is_a?(Presenters::Shared::AppResource)
                                 resource.instance_variable_get('@app_resource')
                               else
                                 resource
                               end
          respond_with_default(unwrapped_resource, location: location, **options)
        end
        f.json { respond_with_default(resource, **options) }
        f.yaml { respond_with_default(resource, **options) }
      end
    end
    alias_method :respond_with_default, :respond_with
    alias_method :respond_with, :respond_with_custom
  end
end
