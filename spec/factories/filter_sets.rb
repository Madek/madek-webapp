FactoryGirl.define do

  factory :filter_set do
    created_at { Time.now }

    association :responsible_user, factory: :user
    association :creator, factory: :user

  end

end
