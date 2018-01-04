module Presenters
  module Vocabularies
    class VocabularyPeople < Presenter

      def initialize(vocabulary, user: nil)
        @vocabulary = vocabulary
        @user = user
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@vocabulary, user: @user)
      end

      def meta_keys_with_people
        meta_key_resources.map do |meta_key|
          {
            meta_key: Presenters::MetaKeys::MetaKeyCommon.new(meta_key),
            keywords: meta_key_people_presenters(meta_key)
          }
        end
      end

      private

      def meta_key_people_presenters(meta_key)
        meta_key_people(meta_key).map do |person|
          Presenters::People::PersonCommon.new(person)
        end
      end

      def meta_key_people(meta_key)
        Person.distinct.joins(
          'inner join meta_data_people on meta_data_people.person_id = people.id'
        ).joins(
          'inner join meta_data on meta_data.id = meta_data_people.meta_datum_id'
        ).where(
          'meta_data.meta_key_id = ?', meta_key.id
        ).reorder('people.first_name').order('people.last_name')
      end

      def meta_key_resources
        @vocabulary.meta_keys.where(
          meta_datum_object_type: 'MetaDatum::People')
      end
    end
  end
end
