module Presenters
  module Shared
    module Modules

      module VocabularyConfig
        extend ActiveSupport::Concern

        included do

          private

          def visible_vocabularies_for_user
            @visible_vocabularies_for_user ||=
              Vocabulary
                .viewable_by_user_or_public(@user)
                .all
                .sort_by
          end

          def usable_vocabularies_for_user
            @usable_vocabularies_for_user ||=
              Vocabulary
                .usable_by_user(@user)
                .all
                .sort_by
          end

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
            @_meta_data_edit_contexts ||=
              _get_app_settings_contexts([:contexts_for_entry_edit])
          end

          def _contexts_for_collection_edit
            @_meta_data_edit_contexts ||=
              _get_app_settings_contexts([:contexts_for_collection_edit])
          end

          def _contexts_for_dynamic_filters
            @_contexts_for_dynamic_filters ||=
              _get_app_settings_contexts([:contexts_for_dynamic_filters])
          end

          # NOTE: visibility of MetaKeys-by-Vocabulary is handled in presenters

          def app_settings
            # There is also AppSetting.first (without s)
            @app_settings ||= AppSettings.first.presence # memo
          end

          # [
          #   :contexts_for_list_details,
          #   :contexts_for_validationx,
          #   :contexts_for_dynamic_filters
          # ].each do |setting_name|
          #   define_method setting_name do
          #     _get_contexts_by_ids(app_settings.try(setting_name))
          #   end
          # end

          # helper:

          def _get_app_settings_contexts(keys)
            _get_contexts_by_ids(
              keys.map do |key|
                app_settings.try(key)
              end.flatten.compact
            )
          end

          def _get_contexts_by_ids(context_list)
            return [] unless context_list.present?
            Context
              .where(id: context_list)
              .sort_by { |c| context_list.index(c.id) } # enforce given order
          end

        end

      end
    end
  end
end
