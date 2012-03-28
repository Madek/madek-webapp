FactoryGirl.define do
  factory :meta_key_definition do
    meta_key {FactoryGirl.create :meta_key}
    meta_context  {FactoryGirl.create :meta_context}
  end
end
