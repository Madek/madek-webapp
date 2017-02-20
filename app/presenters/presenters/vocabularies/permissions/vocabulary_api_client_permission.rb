module Presenters
  module Vocabularies
    module Permissions
      class VocabularyApiClientPermission < \
        Presenters::Shared::Resource::ResourceApiClientPermission

        delegate :view, to: :@app_resource
      end
    end
  end
end
