FactoryGirl.define do

  factory :person do
    lastname {Faker::Name.last_name}
    firstname {Faker::Name.first_name}
  end


end
