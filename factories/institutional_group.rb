FactoryGirl.define do

  factory :institutional_group do
    name {Faker::Name.last_name}
  end

end

