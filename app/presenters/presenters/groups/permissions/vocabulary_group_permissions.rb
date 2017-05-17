module Presenters
  module Groups
    module Permissions
      class VocabularyGroupPermissions < Presenters::Shared::AppResourceWithUser

        delegate :use, to: :@app_resource
        delegate :view, to: :@app_resource

        def initialize(app_resource, user)
          super(app_resource, user)
        end

        def vocabulary
          Presenters::Vocabularies::VocabularyIndex.new(
            @app_resource.vocabulary, user: @user)
        end
      end
    end
  end
end
