
FactoryGirl.define do

  factory :media_set do
    user {User.find_random || (FactoryGirl.create :user)}
  end

end
