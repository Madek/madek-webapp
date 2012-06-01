FactoryGirl.define do

  factory :meta_datum_users do
    meta_key {MetaKey.find_by_id 60} 
  end

end


