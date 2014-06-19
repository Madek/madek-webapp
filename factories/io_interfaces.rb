# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :io_interface do

    id 'default'

    after(:create) do |default_io_interface|

      author_meta_key= MetaKey.find_or_create_by id: "author", 
        meta_datum_object_type:  "MetaDatumPeople"

      FactoryGirl.create :io_mapping,
        io_interface: default_io_interface,
        meta_key:  author_meta_key,
        key_map: "XMP-madek:Author"
    end

  end
end
