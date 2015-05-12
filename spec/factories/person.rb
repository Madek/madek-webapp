FactoryGirl.define do

  factory :person do
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    searchable { "#{first_name} #{last_name}" }
  end

end
