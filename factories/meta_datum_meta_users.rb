FactoryGirl.define do

  factory :meta_datum_users do
    meta_key {MetaKey.find_by_id "uploaded by"} 
    media_resource {FactoryGirl.create :media_resource}
  end

end


