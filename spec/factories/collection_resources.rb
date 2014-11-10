# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection_resource do
    responsible_user_id {(User.find_random || (FactoryGirl.create :user)).id}
    creator_id {(User.find_random || (FactoryGirl.create :user)).id}
    updator_id {(User.find_random || (FactoryGirl.create :user)).id}
  end
end
