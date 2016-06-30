module Presenters
  module Shared
    module Modules

      module VocabularyConfig
        extend ActiveSupport::Concern

        included do

          private

          def visible_vocabularies(user)
            @visible_vocabularies ||= Vocabulary
              .viewable_by_user_or_public(user)
              .all
              .sort_by
          end

          # NOTE: visibility of MetaKeys-by-Vocabulary is handled in presenters

          # TODO: split this up (need UI changes)
          def contexts_for_show
            @contexts_for_show ||=
              _get_contexts_by_ids([
                app_settings.try(:context_for_show_summary),
                app_settings.try(:contexts_for_show_extra)
              ].flatten.compact)
          end

          def app_settings
            @app_settings ||= AppSettings.first.presence # memo
          end

          [
            :contexts_for_list_details,
            :contexts_for_validationx,
            :contexts_for_dynamic_filters
          ].each do |setting_name|
            define_method setting_name do
              _get_contexts_by_ids(app_settings.try(setting_name))
            end
          end

          # helper:

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
