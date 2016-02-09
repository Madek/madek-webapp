module Presenters
  module Shared
    module Modules

      module VocabularyConfig
        extend ActiveSupport::Concern

        # TODO: db config instead of constants
        HARDCODED_CONTEXT_LIST = Madek::Constants::Webapp::UI_CONTEXT_LIST

        included do

          private

          def visible_vocabularies(user)
            @visible_vocabularies ||= Vocabulary
              .viewable_by_user_or_public(user)
              .all
              .sort_by
          end

          def selected_contexts(_user)
            @selected_contexts ||= Context
              .where(id: HARDCODED_CONTEXT_LIST)
              .sort_by { |c| HARDCODED_CONTEXT_LIST.index(c.id) }
          end

        end

      end
    end
  end
end
