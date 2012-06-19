
FactoryGirl.define do

  factory :media_set do
    user {User.find_random || (FactoryGirl.create :user)}
  end

  factory :media_set_with_title, class: "MediaSet" do
    user {User.find_random || (FactoryGirl.create :user)}
    after(:create) do |ms| 
      MetaDatum.create media_resource: ms, meta_key: MetaKey.find_by_label(:title), value: Faker::Lorem.words[0]
    end
  end

end
