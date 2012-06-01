FactoryGirl.define do

  factory :meta_datum_people do
    meta_key {MetaKey.find_by_id 5} 
  end

end


