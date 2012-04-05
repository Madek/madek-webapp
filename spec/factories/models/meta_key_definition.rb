FactoryGirl.define do
  factory :meta_key_definition do
    meta_key {FactoryGirl.create :meta_key}
    meta_context  {FactoryGirl.create :meta_context}
    position {(MetaKeyDefinition.order("position desc").first.try(&:position) || 0) + 1 }
  end
end
