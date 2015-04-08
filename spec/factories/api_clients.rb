FactoryGirl.define do
  factory :api_client do
    login { Faker::Lorem.words(2).join('_').slice(0, 20) }
    description { Faker::Lorem.words(10).join(' ') }
    user { User.find_random || (FactoryGirl.create :user) }
  end
end
