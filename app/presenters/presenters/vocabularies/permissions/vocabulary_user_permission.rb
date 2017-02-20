module Presenters
  module Vocabularies
    module Permissions
      class VocabularyUserPermission < \
        Presenters::Shared::Resource::ResourceUserPermission

        delegate :view, to: :@app_resource
        delegate :use, to: :@app_resource
      end
    end
  end
end
