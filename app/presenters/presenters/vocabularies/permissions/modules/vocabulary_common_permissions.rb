module Presenters
  module Vocabularies
    module Permissions
      module Modules
        module VocabularyCommonPermissions
          extend ActiveSupport::Concern

          included do
            delegate :view, to: :@app_resource
            delegate :use, to: :@app_resource
          end
        end
      end
    end
  end
end
