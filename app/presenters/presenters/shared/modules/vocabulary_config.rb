module Presenters
  module Shared
    module Modules
      module VocabularyConfig
        extend ActiveSupport::Concern
        included do

          def initialize(**args)
            super(**args)
            @memo = nil
          end

          private

          # TODO: db config instead of constants
          def selected_vocabularies(user)
            @memo ||= (
              [Madek::Constants::Webapp::UI_META_CONFIG[:summary_vocabulary]] +
              Madek::Constants::Webapp::UI_META_CONFIG[:displayed_vocabularies])
              .map(&:to_sym)
              .map do |vocab|
                Vocabulary.viewable_by_user_or_public(user).find_by(id: vocab)
              end.compact
          end

        end

      end
    end
  end
end
