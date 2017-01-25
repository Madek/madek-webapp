module Presenters
  module Vocabularies
    class VocabulariesIndex < Presenter

      def initialize(resources, user)
        @resources = resources
        @user = user
      end

      # simple list, no pagination etc
      def resources
        @resources
          .sort_by(&:position)
          .sort_by { |v| v.id == 'madek_core' ? - 1 : 1 }
          .map do |r|
            Presenters::Vocabularies::VocabularyIndex.new(r, user: @user)
          end
      end

      def title
        I18n.t(:sitemap_vocabularies)
      end
    end
  end
end
