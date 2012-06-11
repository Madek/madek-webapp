FactoryGirl.define do

  factory :user do |n| 
    person {FactoryGirl.create :person}
    email {Faker::Internet.email}
    login {Faker::Internet.user_name + "_#{UUIDTools::UUID.random_create.to_s.first 5}"}
    usage_terms_accepted_at {Time.now}
  end

end
