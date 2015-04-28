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

  def get_single_uuid(*uuids)
    if uuids.all?(&:nil?) or uuids.reject(&:nil?).count > 1
      raise 'Invalid list of uuids'
    else
      uuids.find { |uuid| not uuid.nil? }
    end
  end
end
