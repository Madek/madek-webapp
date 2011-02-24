#old#
# -*- encoding : utf-8 -*-
#class ActiveRecord::Base
#  def touch
#    self.update_attribute :updated_at, Time.now
#  end
#
#sellittf#
#     # TODO remove this when is activerecord gem > 3.0.0 or arel > 1.0.1 ??
#     def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
#        attrs = {}
#        attribute_names.each do |name|
#          if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
#
#            if include_readonly_attributes || (!include_readonly_attributes && !self.class.readonly_attributes.include?(name))
#              value = read_attribute(name)
#
#              if value && self.class.serialized_attributes.key?(name)
#                value = YAML.dump value
#              end
#              attrs[self.class.arel_table[name]] = value
#            end
#          end
#        end
#        attrs
#      end
#end
