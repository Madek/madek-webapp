class Person < ActiveRecord::Base

  # include PersonModules::TextSearch

  has_one :user

  has_and_belongs_to_many :meta_data, join_table: :meta_data_people

  validate do
    errors.add(:base, 'Name cannot be blank') if [first_name, last_name, pseudonym].all?(&:blank?)
  end

end
