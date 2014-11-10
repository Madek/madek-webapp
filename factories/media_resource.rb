
FactoryGirl.define do

  factory :media_resource do
    user {User.find_random || (FactoryGirl.create :user)}
    factory :media_resource_with_title, class: "MediaResource" do
      after(:create) do |ms| 
        meta_key = MetaKey.find_by_id(:title) || FactoryGirl.create(:meta_key_title)
        ms.meta_data.create meta_key: meta_key, value: Faker::Lorem.words[0]
        ms.reindex
      end
    end
  end


##################################################################

  factory :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}
    after :create do |mei|
      FactoryGirl.create :media_file_for_image, media_entry: mei
    end
  end

  factory :media_entry_incomplete_for_image, class: :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}
    after :create do |mei|
      FactoryGirl.create :media_file_for_image, media_entry: mei
    end
  end


  factory :media_entry_incomplete_for_movie, class: :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}
    after :create do |mei|
      FactoryGirl.create :media_file_for_movie, media_entry: mei
    end
  end


##################################################################

  factory :filter_set do
    user {User.find_random || (FactoryGirl.create :user)}
    settings {}
    
    factory :filter_set_with_title, class: "FilterSet" do
      after(:create) do |ms| 
        meta_key = MetaKey.find_by_id(:title) || FactoryGirl.create(:meta_key_title)
        ms.meta_data.create meta_key: meta_key, value: Faker::Lorem.words[0]
      end
    end
  end

end
