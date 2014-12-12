FactoryGirl.define do

  factory :collection do
    before(:create) do |collection|
      collection.responsible_user_id = (User.find_random || FactoryGirl.create(:user)).id
      collection.creator_id = (User.find_random || FactoryGirl.create(:user)).id
    end
  end

  factory :collection_with_title, class: 'Collection' do
    # raise "not implemented yet"
  end

end
