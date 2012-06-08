
FactoryGirl.define do

  factory :media_resource do
    user {User.find_random || (FactoryGirl.create :user)}
  end
  
end
