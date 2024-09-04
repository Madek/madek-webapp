module MediaResources
  module CrudActions
    extend ActiveSupport::Concern
    include ControllerHelpers

    def show
      represent
    end

    def list_meta_data
      resource = get_authorized_resource
      respond_with(
        Presenters::MediaResources::MediaResourceListMetadata.new(
          resource,
          current_user
        )
      )
    end

    def index
      resources = auth_policy_scope(current_user, model_klass)
      @get = presenterify(resources, nil)
      respond_with @get
    end
  end
end
