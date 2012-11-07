
FactoryGirl.define do

  factory :media_resource do
    user {User.find_random || (FactoryGirl.create :user)}
    factory :media_resource_with_title, class: "MediaResource" do
      after(:create) do |ms| 
        meta_key = MetaKey.find_by_label(:title) || FactoryGirl.create(:meta_key_title)
        ms.meta_data.create meta_key: meta_key, value: Faker::Lorem.words[0]
        ms.reindex
      end
    end
  end

##################################################################

  factory :media_entry do
    user {User.find_random || (FactoryGirl.create :user)}
    media_file {FactoryGirl.create :media_file}
    factory :media_entry_with_title, class: "MediaEntry" do
      after(:create) do |ms| 
        meta_key = MetaKey.find_by_label(:title) || FactoryGirl.create(:meta_key_title)
        ms.meta_data.create meta_key: meta_key, value: Faker::Lorem.words[0]
        ms.reindex
      end
    end
  end

  factory :media_entry_incomplete do
    user {User.find_random || (FactoryGirl.create :user)}

    uploaded_data  do
      f = "#{Rails.root}/features/data/images/berlin_wall_01.jpg"

      # Need to copy this file to a temporary new file because files are moved away after succesful
      # uploads!
      f_temp = "#{Rails.root}/tmp/#{File.basename(f)}"

      FileUtils.cp(f, f_temp)
      ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f_temp)),
                                             :tempfile=> File.new(f_temp, "r"),
                                             :filename=> File.basename(f_temp))
    end
  end

##################################################################

  factory :media_set do
    user {User.find_random || (FactoryGirl.create :user)}
    
    factory :media_set_with_title, class: "MediaSet" do
      after(:create) do |ms| 
        meta_key = MetaKey.find_by_label(:title) || FactoryGirl.create(:meta_key_title)
        ms.meta_data.create meta_key: meta_key, value: Faker::Lorem.words[0]
        ms.reindex
      end
    end
  end

  factory :filter_set do
    user {User.find_random || (FactoryGirl.create :user)}
    settings {}
    
    factory :filter_set_with_title, class: "FilterSet" do
      after(:create) do |ms| 
        meta_key = MetaKey.find_by_label(:title) || FactoryGirl.create(:meta_key_title)
        ms.meta_data.create meta_key: meta_key, value: Faker::Lorem.words[0]
      end
    end
  end

end
