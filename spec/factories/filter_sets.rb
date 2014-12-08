FactoryGirl.define do

  factory :filter_set do

    association :responsible_user, factory: :user
    association :creator, factory: :user

  end

end
