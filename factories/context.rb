FactoryGirl.define do

  factory :context do
    id {Faker::Lorem.words.join("_")}
    label { id }

    context_group {}
    
    factory :context_core do
      id :core
      after(:create) do |f|
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "title")
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "subtitle")
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "author", :meta_datum_object_type => "MetaDatumPeople")
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "portrayed object dates", :meta_datum_object_type => "MetaDatumDate")
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "keywords", :meta_datum_object_type => "MetaDatumKeywords")
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "copyright notice")
        FactoryGirl.create :meta_key_definition, :context => f, :meta_key => (FactoryGirl.create :meta_key, id: "owner", :meta_datum_object_type => "MetaDatumUsers")
      end
    end    
    
  end
end
