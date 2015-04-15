module Concerns
  module MediaResources
    module Filters
      module Filters
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::Helpers

        included do
          scope :filter_by_public_view, lambda { |bool|
            where(get_metadata_and_previews: bool)
          }
        end

        module ClassMethods
          def filter(meta_data: nil, media_file_specs: nil, permission_specs: nil)
            # NOTE: for the sake of sanity when analyzing the generated sql
            # and to prevent strange active record generation strategies
            sql = "((#{(current_scope or unscoped).to_sql}) " \
                   'INTERSECT ' \
                   "(#{filter_by_permissions(*permission_specs).to_sql}) " \
                   'INTERSECT ' \
                   "(#{filter_by_media_files(*media_file_specs).to_sql}) " \
                   'INTERSECT ' \
                   "(#{filter_by_meta_data(*meta_data).to_sql})) " \
                  "AS #{model_name.plural}"
            from(sql)
          end

          def filter_by_meta_data(*meta_data)
            unless meta_data.blank?
              query_strings = meta_data.map do |meta_datum|
                raise 'Value can\'t be an array' if meta_datum[:value].is_a?(Array)
                type = \
                  (meta_datum[:type] \
                   or MetaKey.find(meta_datum[:key]).meta_datum_object_type)
                unscoped.filter_by_meta_datum(meta_datum[:key],
                                              type,
                                              meta_datum[:value]).to_sql
              end
              from \
                join_query_strings_with_intersect \
                  *query_strings
            else
              all
            end
          end

          def filter_by_media_files(*media_file_specs)
            each_with_method_chain(:filter_by_media_file_helper,
                                   *media_file_specs)
          end

          def filter_by_permissions(*permission_specs)
            each_with_method_chain(:filter_by_permission_helper,
                                   *permission_specs)
          end

          def each_with_method_chain(method, *key_value_specs)
            result = (current_scope or all)
            key_value_specs.each do |key_value_spec|
              result = \
                result.send(method,
                            key: key_value_spec[:key],
                            value: key_value_spec[:value])
            end
            result
          end

          def filter_by_media_file_helper(key: nil, value: nil)
            filter = joins(:media_file)
            unless value == 'any'
              filter = filter.where(media_files: Hash[key, value])
            end
            filter
          end

          def filter_by_permission_helper(key: nil, value: nil)
            case key
            when 'responsible_user'
              filter_by_responsible_user(value)
            when 'public'
              filter_by_public_view(value)
            when 'entrusted_to_group'
              entrusted_to_group Group.find(value)
            when 'entrusted_to_user'
              entrusted_to_user User.find(value)
            end
          end
        end
      end
    end
  end
end
