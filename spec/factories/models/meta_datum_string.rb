FactoryGirl.define do

  factory :meta_datum_string do
    string {Faker::Lorem.words.join(" ")}
    meta_key {MetaKey.find_by_label "title"}
  end

end


