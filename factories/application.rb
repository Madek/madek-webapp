

FactoryGirl.define do
  factory :application, class: API::Application do
    id {Faker::Lorem.words(2).join('_').slice(0,20)}
    description {Faker::Lorem.words(10).join(' ')}
  end
end
