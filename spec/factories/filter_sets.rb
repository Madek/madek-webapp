FactoryGirl.define do

  factory :filter_set do

    title { Faker::Name.title }
    association :responsible_user, factory: :user
    association :creator, factory: :user

  end

end
