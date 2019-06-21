module Presenters
  module Shared
    module Modules

      module VocabularyConfig
        extend ActiveSupport::Concern

        included do

          private

          def _entry_summary_context
            @_entry_summary_context ||=
              _get_app_settings_contexts([:context_for_entry_summary])
          end

          def _collection_summary_context
            @_collection_summary_context ||=
              _get_app_settings_contexts([:context_for_collection_summary])
          end

          def _contexts_for_entry_extra
            @_contexts_for_entry_extra ||=
              _get_app_settings_contexts([:contexts_for_entry_extra])
          end

          def _contexts_for_entry_edit
            @_contexts_for_entry_edit ||=
              _get_app_settings_contexts([:contexts_for_entry_edit])
          end

          def _contexts_for_collection_extra
            @_contexts_for_collection_extra ||=
              _get_app_settings_contexts([:contexts_for_collection_extra])
          end

          def _contexts_for_collection_edit
            @_contexts_for_collection_edit ||=
              _get_app_settings_contexts([:contexts_for_collection_edit])
          end

          def _contexts_for_dynamic_filters
            @_contexts_for_dynamic_filters ||=
              _get_app_settings_contexts([:contexts_for_dynamic_filters])
          end

          def _contexts_for_list_details
            @_contexts_for_list_details ||=
              _get_app_settings_contexts([:contexts_for_list_details])
          end

          # NOTE: visibility of MetaKeys-by-Vocabulary is handled in presenters

          def app_settings
            # There is also AppSetting.first (without s)
            @app_settings ||= AppSetting.first.presence # memo
          end

          # helper:

          def _get_app_settings_contexts(keys)
            keys.map do |key|
              app_settings.try(key)
            end.flatten.compact
          end

        end
      end
    end
  end
end
