module Presenters
  module Vocabularies
    module Permissions
      class VocabularyPublicPermission < \
        Presenters::Shared::Resource::ResourcePublicPermission

        # NOTE: better naming in DB then Entry etc, make generic names for UI here:

        def use
          @app_resource.enabled_for_public_use
        end

        def view
          @app_resource.enabled_for_public_view
        end

      end
    end
  end
end
