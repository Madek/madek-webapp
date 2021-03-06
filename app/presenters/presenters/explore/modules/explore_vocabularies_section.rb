module Presenters
  module Explore
    module Modules
      class ExploreVocabulariesSection < Presenter

        include AuthorizationSetup

        def initialize(user, settings)
          @user = user
          @settings = settings
        end

        def empty?
          vocabularies.blank?
        end

        def content
          return if empty?
          {
            type: 'vocabularies',
            id: 'vocabularies',
            data: vocabularies_overview,
            show_all_link: true,
            show_all_text: I18n.t(:explore_vocabulary_section_show_details),
            show_title: true
          }
        end

        private

        def vocabularies_overview
          {
            title: I18n.t(:explore_vovabulary_section_title),
            url: vocabularies_path,
            list: vocabularies
          }
        end

        def vocabularies
          @vocabularies ||= begin
            authorized_resources = auth_policy_scope(@user, Vocabulary.all)
            authorized_resources.map do |vocabulary|
              Presenters::Vocabularies::VocabularyIndex.new(
                vocabulary, user: @user)
            end
          end
        end
      end
    end
  end
end
