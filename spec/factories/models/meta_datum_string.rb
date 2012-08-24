FactoryGirl.define do

  factory :meta_datum_string do
    string {Faker::Lorem.words.join(" ")}
    meta_key {MetaKey.find_by_label("title") || FactoryGirl.create(:meta_key_title) }
    media_resource {FactoryGirl.create :media_resource}
  end

end


