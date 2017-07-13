module Presenters
  module MediaEntries
    class BatchDiffQuery < ActiveRecord::Base

      def self.diff(clazz, initial_scope)
        run diff_query(clazz, initial_scope)
      end

      private_class_method

      def self.run(query)
        connection.exec_query(query).to_hash
      end

      def self.final_query(clazz, base)
        singular = clazz.name.underscore

        <<-SQL

          with
          sub1
          as
          (
            #{base.to_sql}
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

      def self.diff_query(clazz, initial_scope)
        final_query(clazz, initial_scope)
      end
    end
  end
end
