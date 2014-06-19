FactoryGirl.define do
  factory :meta_key_definition do
    meta_key {FactoryGirl.create :meta_key}
    context  {FactoryGirl.create :context}
    position {MetaKeyDefinition.maximum(:position).to_i + 1 }
  end
end
