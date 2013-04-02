FactoryGirl.define do

  factory :meta_datum_people do
    meta_key {MetaKey.find_by_id("author") || FactoryGirl.create(:meta_key_author)} 
    media_resource {FactoryGirl.create :media_resource}
  end

end


