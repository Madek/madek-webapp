FactoryGirl.define do
  factory :meta_key_definition do
    meta_key {FactoryGirl.create :meta_key}
    meta_context  {FactoryGirl.create :meta_context}
    position {MetaKeyDefinition.maximum(:position).to_i + 1 }
    key_map { nil }
  end
end
