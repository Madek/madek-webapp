#sellittf#
class ActiveRecord::Associations::Association
  def build_record_with_owner(attributes, options)
    new_attributes = scoped.scope_for_create.symbolize_keys.merge(attributes)
    build_record_without_owner(new_attributes, options)
  end
  alias_method_chain :build_record, :owner
end
