FactoryGirl.define do

  factory :meta_datum_meta_terms do
    meta_key {MetaKey.find_by_id 22} # the author
  end

end


