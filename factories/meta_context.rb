FactoryGirl.define do

  factory :meta_context do
    name {Faker::Lorem.words.join("_")}
    is_user_interface { true }

    label do
      h = {}
      LANGUAGES.each {|lang| h[lang] = name }
      h
    end

    meta_context_group {}
    
    factory :meta_context_core do
      name :core
      after(:create) do |f|
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "title")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "subtitle")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "author", :meta_datum_object_type => "MetaDatumPeople")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "portrayed object dates", :meta_datum_object_type => "MetaDatumDate")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "keywords", :meta_datum_object_type => "MetaDatumKeywords")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "copyright notice")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, id: "owner", :meta_datum_object_type => "MetaDatumUsers")
      end
    end    
    
    factory :meta_context_io_interface do
      name :io_interface
      is_user_interface false
      after(:create) do |f|
        FactoryGirl.create :meta_key_definition, :meta_context => f,
                                                 :meta_key => (FactoryGirl.create :meta_key, id: "author", :meta_datum_object_type => "MetaDatumPeople"),
                                                 :key_map => "XMP-madek:Author"
      end
    end    
    
  end


end
