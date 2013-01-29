FactoryGirl.define do

  factory :group do
    name {Faker::Name.last_name}
  end

end
