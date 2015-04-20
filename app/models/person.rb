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
end
