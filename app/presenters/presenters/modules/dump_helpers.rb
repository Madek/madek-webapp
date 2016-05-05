module Presenters
  module Modules
    module DumpHelpers
      extend ActiveSupport::Concern

      module ClassMethods
        def dump_recur(obj)
          deal_with_obj_type(obj) \
            or deal_with_obj_class(obj) \
            or obj
        end

        def deal_with_obj_type(obj)
          if obj.is_a?(Presenter)
            obj.full_dump
          elsif obj.is_a?(Array)
            obj.map { |elt| dump_recur(elt) }
          elsif (obj.is_a?(Pojo) or obj.is_a?(Hash))
            obj.to_h
              .map { |k, v| [k, dump_recur(v)] }
              .to_h
          end.presence.try(:compact)
        end

        def deal_with_obj_class(obj)
          if obj.class.name =~ /ActiveRecord/
            "!!!ACTIVE_RECORD!!! <##{obj.class}>"
          elsif obj.class.superclass.name =~ /ActiveRecord/
            "!!!ACTIVE_RECORD!!! #{obj}"
          end
        end

        def delegate_to(inst_var, *args)
          args.each { |m| delegate m, to: inst_var }
        end

        def deep_map(h_spec, obj)
          Hash[
            h_spec.map do |key, value|
              if value.class == Hash or value.class == Array
                [key, apply(key, value, obj)]
              else
                raise 'Sparse dump: only Hash or Array as value permitted!'
              end
            end.compact
          ]
        end

        def apply(key, value, obj)
          realized_obj = realize_object(key, obj)

          if value.class == Hash
            apply_hash_value(value, realized_obj)
          elsif value.class == Array
            apply_array_value(value, realized_obj)
          end
        end

        def apply_array_value(array_v, array_of_obj)
          if array_v.empty?
            dump_recur(obj)
          elsif array_v.length == 1
            spec = array_v.first
            array_of_obj.map { |obj| deep_map(spec, obj) }
          else
            raise 'Sparse dump: array has more than 1 element!'
          end
        end

        def apply_hash_value(value, obj)
          if value.blank?
            dump_recur(obj)
          else
            deep_map(value, obj)
          end
        end

        def realize_object(key, obj)
          if obj.class < Presenter
            obj.send(key)
          elsif obj.class == Pojo
            obj.send(key)
          elsif obj.class == Hash
            obj[key]
          else
            raise 'Unspecified object type'
          end
        end
      end
    end
  end
end
