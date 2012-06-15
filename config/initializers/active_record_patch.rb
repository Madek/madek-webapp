#sellittf# FIXME this is just a monkey patch
class ActiveRecord::Associations::Association
  def build_record_with_owner(attributes, options)
    if reflection.klass == MetaDatum and (attributes.keys & [:media_resource, :media_resource_id]).empty?
      attributes = {:media_resource => owner}.merge(attributes)
    end
    build_record_without_owner(attributes, options)
  end
  alias_method_chain :build_record, :owner
end
