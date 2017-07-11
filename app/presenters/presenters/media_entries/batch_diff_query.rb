# rubocop:disable Metrics/ClassLength
module Presenters
  module MediaEntries
    class BatchDiffQuery < ActiveRecord::Base

      def self.diff(clazz, collection_id: nil, resource_ids: nil)
        run diff_query(
          clazz,
          collection_id: collection_id,
          resource_ids: resource_ids
        )
      end

      private_class_method

      def self.run(query)
        connection.exec_query(query).to_hash
      end

      def self.child_collections(collection_id)
        <<-SQL
          select
            collections.id
          from
            collections,
            collection_collection_arcs
          where
            collections.id = collection_collection_arcs.child_id
            and collection_collection_arcs.parent_id = '#{collection_id}'
        SQL
      end

      def self.child_media_entries(collection_id)
        <<-SQL
          select
            media_entries.id
          from
            media_entries,
            collection_media_entry_arcs
          where
            media_entries.id = collection_media_entry_arcs.media_entry_id
            and collection_media_entry_arcs.media_entry_id = '#{collection_id}'
        SQL
      end

      def self.explicit_resources(clazz, resource_ids)
        plural = clazz.name.underscore.pluralize
        ids_string_list = resource_ids.map { |id| "'#{id}'" }.join(', ')
        <<-SQL
          select
            #{plural}.id
          from
            #{plural}
          where
            #{plural}.id in (
              #{ids_string_list}
            )
        SQL
      end

      def self.base_scope(clazz, collection_id: nil, resource_ids: nil)
        if collection_id
          if clazz == MediaEntry
            child_media_entries(collection_id)
          else
            child_collections(collection_id)
          end
        else
          explicit_resources(clazz, resource_ids)
        end
      end

      def self.final_query(clazz, base)
        singular = clazz.name.underscore

        <<-SQL

          with
          sub1
          as
          (
            #{base}
          )
          ,
          sub4
          as

          (

          	(



          		select
          			sub2.meta_key_id as meta_key_id, sub2.meta_data_type, null as multi_values, sub2.string as single_value, count(sub2.#{singular}_id) as resource_count
          		from
          		(

          				select
          					meta_data.meta_key_id as meta_key_id, meta_data.#{singular}_id as #{singular}_id, meta_data.string as string, meta_data.type as meta_data_type
          				from
          					sub1,
          					meta_data
          				where
          					meta_data.#{singular}_id = sub1.id
          					and (meta_data.type = 'MetaDatum::Text' or meta_data.type = 'MetaDatum::TextDate')
          				order by
          					meta_data.meta_key_id, meta_data.#{singular}_id, meta_data.string

          		) as sub2

          		group by
          			(sub2.meta_key_id, sub2.string, sub2.meta_data_type)

          		order by
          			meta_key_id asc, resource_count desc

          	)

          	union all

          	(

          		select
          			sub2.meta_key_id as meta_key_id, sub2.meta_data_type, sub2.value_ids as multi_values, null as single_value, count(sub2.#{singular}_id) as resource_count
          		from
          		(

          			select
          				sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type, array_agg(sub.keyword_id) as value_ids

          			from
          			(

          				select
          					meta_data.meta_key_id as meta_key_id, meta_data.#{singular}_id as #{singular}_id, meta_data_keywords.keyword_id as keyword_id, meta_data.type as meta_data_type
          				from
          					sub1,
          					meta_data,
          					meta_data_keywords
          				where
                    meta_data.#{singular}_id = sub1.id
          					and meta_data.type = 'MetaDatum::Keywords'
          					and meta_data_keywords.meta_datum_id = meta_data.id
          				order by
          					meta_data.meta_key_id, meta_data.#{singular}_id, meta_data_keywords.keyword_id

          			) as sub

          			group by
          				(sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type)
          		) as sub2

          		group by
          			(sub2.meta_key_id, sub2.value_ids, sub2.meta_data_type)

          		order by
          			meta_key_id asc, resource_count desc
          	)

          	union all
          	(

          		select
          			sub2.meta_key_id as meta_key_id, sub2.meta_data_type, sub2.value_ids as multi_values, null as single_value, count(sub2.#{singular}_id) as resource_count
          		from
          		(

          			select
          				sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type, array_agg(sub.person_id) as value_ids

          			from
          			(

          				select
          					meta_data.meta_key_id as meta_key_id, meta_data.#{singular}_id as #{singular}_id, meta_data_people.person_id as person_id, meta_data.type as meta_data_type
          				from
          					sub1,
          					meta_data,
          					meta_data_people
          				where
                    meta_data.#{singular}_id = sub1.id
          					and meta_data.type = 'MetaDatum::People'
          					and meta_data_people.meta_datum_id = meta_data.id
          				order by
          					meta_data.meta_key_id, meta_data.#{singular}_id, meta_data_people.person_id

          			) as sub

          			group by
          				(sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type)
          		) as sub2

          		group by
          			(sub2.meta_key_id, sub2.value_ids, sub2.meta_data_type)

          		order by
          			meta_key_id asc, resource_count desc
          	)
          )

          select
          	meta_key_id,
            max(resource_count),
            (select count(1) from sub1)
          from
          	sub4
          group by
          	meta_key_id
        SQL
      end

      def self.diff_query(clazz, collection_id: nil, resource_ids: nil)
        if collection_id && resource_ids || !collection_id && !resource_ids
          throw "Unexpected parameters: #{collection_id}, #{resource_ids}"
        end
        if resource_ids && !resource_ids.any?
          throw "Unexpected parameters: #{resource_ids}"
        end

        base = base_scope(
          clazz,
          collection_id: collection_id,
          resource_ids: resource_ids)

        final_query(clazz, base)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
