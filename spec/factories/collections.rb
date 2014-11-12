FactoryGirl.define do

  factory :collection do
    before(:create) do |collection|
    end
  end

  factory :collection_with_title, class: "Collection" do
    # raise "not implemented yet" 
  end

end

