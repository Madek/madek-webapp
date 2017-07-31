module Presenters
  module Explore
    module Modules
      module ValuesForMetaKey

        include AuthorizationSetup
        include Presenters::Explore::Modules::KeywordsForMetaKey
        include Presenters::Explore::Modules::PeopleForMetaKey

        private

        def shared_meta_key_values(
          meta_key,
          user,
          load_entries,
          page_size: nil,
          start_index: nil)

          page_size = 3 unless page_size
          start_index = 0 unless start_index

          scope = meta_key_values_scope(meta_key, user)

          frame = scope.distinct
          .limit(page_size + 1)
          .offset(start_index)

          has_more = frame.length > page_size

          presenters = frame.slice(0, page_size).map do |value|
            presenter_by_meta_key(meta_key).new(value, user, load_entries)
          end

          {
            values: presenters,
            has_more: has_more,
            page_size: page_size,
            start_index: start_index
          }
        end

        def meta_key_values_scope(meta_key, user)
          case meta_key.meta_datum_object_type
          when 'MetaDatum::Keywords'
            keywords_for_meta_key_and_visible_entries(user, meta_key)
          when 'MetaDatum::People'
            people_for_meta_key_and_visible_entries(user, meta_key)
          else
            throw 'Unexpected type: ' + meta_key.meta_datum_object_type
          end
        end

        def presenter_by_meta_key(meta_key)
          case meta_key.meta_datum_object_type
          when 'MetaDatum::Keywords'
            Presenters::Explore::KeywordExamplesForExplore
          when 'MetaDatum::People'
            Presenters::Explore::PersonExamplesForExplore
          else
            throw 'Unexpected type: ' + meta_key.meta_datum_object_type
          end
        end
      end
    end
  end
end
