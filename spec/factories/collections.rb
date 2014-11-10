FactoryGirl.define do

  factory :collection do
    before(:create) do |collection|
      collection.resource= FactoryGirl.create :collection_resource
      collection.id= collection.resource.id
    end
  end

  factory :collection_with_title, class: "Collection" do
    # raise "not implemented yet" 
  end

end

