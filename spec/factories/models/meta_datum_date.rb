FactoryGirl.define do

  factory :meta_datum_date do
    meta_key_id {MetaKey.find_by_id(8).id}
    meta_date_from {FactoryGirl.create :meta_date}
    meta_date_to {FactoryGirl.create :meta_date}
  end

end


