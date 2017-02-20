module Presenters
  module Vocabularies
    module Permissions
      class VocabularyGroupPermission < \
        Presenters::Shared::Resource::ResourceGroupPermission

        delegate :view, to: :@app_resource
        delegate :use, to: :@app_resource
      end
    end
  end
end
