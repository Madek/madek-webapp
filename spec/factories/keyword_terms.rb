FactoryGirl.define do
  factory :keyword_term do
    term { Faker::Lorem.words.join(' ') }
  end
end
