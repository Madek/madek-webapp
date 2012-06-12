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
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "title")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "subtitle")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "author", :meta_datum_object_type => "MetaDatumPeople")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "portrayed object dates ", :meta_datum_object_type => "MetaDatumDate")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "keywords", :meta_datum_object_type => "MetaDatumKeywords")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "copyright notice")
        FactoryGirl.create :meta_key_definition, :meta_context => f, :meta_key => (FactoryGirl.create :meta_key, :label => "owner", :is_dynamic => true, :meta_datum_object_type => "MetaDatumUsers")
      end
    end    
    
    factory :meta_context_io_interface do
      name :io_interface
      is_user_interface false
      after(:create) do |f|
        FactoryGirl.create :meta_key_definition, :meta_context => f,
                                                 :meta_key => (FactoryGirl.create :meta_key, :label => "author", :meta_datum_object_type => "MetaDatumPeople"),
                                                 :key_map => "XMP-madek:Author"
      end
    end    
    
  end


end
