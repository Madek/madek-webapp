module Presenters
  module Shared
    module Modules

      module VocabularyConfig

        # TODO: db config instead of constants
        HARDCODED_CONTEXT_LIST = [
          # summary context/"Das Wichtigste":
          'core', # NOT 'madek_core' vocab!!!
          # 4 extra contexts:
          #    ZHdK     |       Werk     |    Personen   |   Rechte
          'zhdk_bereich', 'media_content', 'media_object', 'copyright'
        ]

        extend ActiveSupport::Concern
        included do

          def initialize(**args)
            super(**args)
          end

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
