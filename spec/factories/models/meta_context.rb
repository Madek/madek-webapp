FactoryGirl.define do

  factory :meta_context do
    name {Faker::Lorem.words.join("_")}
    is_user_interface true

    label do
      h = {}
      LANGUAGES.each do |lang|
        h[lang] = name
      end
      h
    end

    meta_context_group {}
  end


end
