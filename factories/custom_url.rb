FactoryGirl.define do
  factory :custom_url do
    id "shit-in-my-head"
    media_resource {MediaEntry.find_by_title("Shit in my Head")}
    creator {FactoryGirl.create(:user)}
    updator {FactoryGirl.create(:user)}
  end
end
