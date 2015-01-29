FactoryGirl.define do

  factory :group do
    name { Faker::Name.last_name }

    trait :with_user do
      after(:create) do |group|
        group.users << create(:user)
      end
    end
  end
end
