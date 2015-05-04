module UuidHelper
  SUPPORTED_REDIRECTION_CLASSES = [
    MediaEntry,
    Collection,
    FilterSet,
    Person
  ]

  def find_resource_by_uuid(resource_uuid)
    SUPPORTED_REDIRECTION_CLASSES
      .map { |klass| begin klass.send(:find, resource_uuid) rescue nil end }
      .reject(&:nil?)
      .first # just take it, there can not be more than one because UUIDs
  end
end
