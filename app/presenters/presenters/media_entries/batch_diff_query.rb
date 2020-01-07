module Presenters
  module MediaEntries
    # rubocop:disable Metrics/ClassLength
    class BatchDiffQuery < ActiveRecord::Base
      class << self
        def diff(clazz, initial_scope, covered_types: MetaKey.object_types)
          check_meta_data_coverage(clazz, initial_scope, covered_types)
          run diff_query(clazz, initial_scope)
        end

        private

        def run(query)
          connection.exec_query(query).to_hash
        end

        def check_meta_data_coverage(klass, base, covered_types)
          singular = klass.name.underscore

          meta_data_types = run(
            <<-SQL
              with
              base_query
              as
              (
                #{base.to_sql}
              )
              select
                meta_data.type as meta_data_type
              from
                base_query,
                meta_data
              where
                meta_data.#{singular}_id = base_query.id
              group by
                meta_data_type
            SQL
          ).map(&:values).flatten

          unless (missing_types = meta_data_types - covered_types).empty?
            missing_types.map! { |ms| "<#{ms}>" }
            raise 'Missing query for the following '\
                  "meta data types: #{missing_types.join(', ')}"
          end
        end

        def final_query(clazz, base)
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
                      meta_data.meta_key_id as meta_key_id,
                      meta_data.#{singular}_id as #{singular}_id,
                      (
                        case
                        when meta_data.type = 'MetaDatum::JSON' then meta_data.json::text
                        when meta_data.type = 'MetaDatum::MediaEntry' then meta_data.other_media_entry_id || meta_data.string
                        else meta_data.string
                        end
                      ) as string,
                      meta_data.type as meta_data_type
                    from
                      sub1,
                      meta_data
                    where
                      meta_data.#{singular}_id = sub1.id
                      and (meta_data.type = ANY('{MetaDatum::Text,MetaDatum::TextDate,MetaDatum::JSON,MetaDatum::MediaEntry}'))
                    order by
                      meta_data.meta_key_id,
                      meta_data.#{singular}_id,
                      case when meta_data.type = 'MetaDatum::JSON' then meta_data.json::text else meta_data.string end

                ) as sub2

                group by
                  (sub2.meta_key_id, sub2.string, sub2.meta_data_type)

                order by
                  meta_key_id asc, resource_count desc
              )

              union all

              #{meta_datum_keywords_query(singular)}

            	union all

              #{meta_datum_people_query(singular)}

              union all

              #{meta_datum_roles_query(singular)}
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

        def meta_datum_keywords_query(singular)
          <<-SQL
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
          SQL
        end

        def meta_datum_people_query(singular)
          <<-SQL
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
          SQL
        end

        def meta_datum_roles_query(singular)
          <<-SQL
            (
              select
                sub2.meta_key_id as meta_key_id, sub2.meta_data_type, sub2.value_ids as multi_values, null as single_value, count(sub2.#{singular}_id) as resource_count
              from
              (

                select
                  sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type, array_agg(sub.person_role_id) as value_ids

                from
                (

                  select
                    meta_data.meta_key_id as meta_key_id, meta_data.#{singular}_id as #{singular}_id, ARRAY [meta_data_roles.person_id, meta_data_roles.role_id] as person_role_id, meta_data.type as meta_data_type
                  from
                    sub1,
                    meta_data,
                    meta_data_roles
                  where
                    meta_data.#{singular}_id = sub1.id
                    and meta_data.type = 'MetaDatum::Roles'
                    and meta_data_roles.meta_datum_id = meta_data.id
                  order by
                    meta_data.meta_key_id, meta_data.#{singular}_id, meta_data_roles.person_id, meta_data_roles.role_id

                ) as sub

                group by
                  (sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type)
              ) as sub2

              group by
                (sub2.meta_key_id, sub2.value_ids, sub2.meta_data_type)

              order by
                meta_key_id asc, resource_count desc
            )
          SQL
        end

        def meta_datum_media_entry_query(singular)
          <<-SQL
            (
              select
                sub2.meta_key_id as meta_key_id, sub2.meta_data_type, sub2.value_ids as multi_values, null as single_value, count(sub2.#{singular}_id) as resource_count
              from
              (

                select
                  sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type, array_agg(sub.person_role_id) as value_ids

                from
                (

                  select
                    meta_data.meta_key_id as meta_key_id, meta_data.#{singular}_id as #{singular}_id, ARRAY [meta_data_roles.person_id, meta_data_roles.role_id] as person_role_id, meta_data.type as meta_data_type
                  from
                    sub1,
                    meta_data,
                    meta_data_roles
                  where
                    meta_data.#{singular}_id = sub1.id
                    and meta_data.type = 'MetaDatum::Roles'
                    and meta_data_roles.meta_datum_id = meta_data.id
                  order by
                    meta_data.meta_key_id, meta_data.#{singular}_id, meta_data_roles.person_id, meta_data_roles.role_id

                ) as sub

                group by
                  (sub.meta_key_id, sub.#{singular}_id, sub.meta_data_type)
              ) as sub2

              group by
                (sub2.meta_key_id, sub2.value_ids, sub2.meta_data_type)

              order by
                meta_key_id asc, resource_count desc
            )
          SQL
        end

        def diff_query(clazz, initial_scope)
          final_query(clazz, initial_scope)
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
