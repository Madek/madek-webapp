FactoryGirl.define do

  factory :vocabulary do
    id { Faker::Internet.slug(nil, '-') }
    label { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end

end
