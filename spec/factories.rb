FactoryGirl.define do

  factory :person do
    lastname {Faker::Name.last_name}
    firstname {Faker::Name.first_name}
  end

  factory :user do
    person {FactoryGirl.create :person}
    email {"#{person.firstname}.#{person.lastname}@example.com".downcase} 
    login {email}
  end

end
