class Person < ActiveRecord::Base

  # include PersonModules::TextSearch

  has_one :user

  has_and_belongs_to_many :meta_data, join_table: :meta_data_people

  validate do
    if [first_name, last_name, pseudonym].all?(&:blank?)
      errors.add(:base, 'Name cannot be blank')
    end
  end

  def to_s
    case
    when ((first_name or last_name) and (pseudonym and !pseudonym.try(:empty?)))
      "#{first_name} #{last_name} (#{pseudonym})"
    when (first_name or last_name)
      "#{first_name} #{last_name}"
    else
      "#{pseudonym}"
    end
  end

  # NOTE: disable this cop as we are defining a method according
  # to standard rails naming convention
  # rubocop:disable Style/PredicateName
  def self.has_many_through_meta_data(specific_media_resources)
    define_method specific_media_resources do
      specific_media_resources.to_s.singularize.camelize.constantize
        .joins(:meta_data)
        .joins('INNER JOIN meta_data_people ' \
               'ON meta_data.id = meta_data_people.meta_datum_id')
        .where(meta_data_people: { person_id: id })
        .uniq
    end
  end
  # rubocop:enable Style/PredicateName

  private_class_method :has_many_through_meta_data

  has_many_through_meta_data :media_entries
  has_many_through_meta_data :collections
  has_many_through_meta_data :filter_sets
end
