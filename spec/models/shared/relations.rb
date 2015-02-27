RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_responds_to, 'it responds to'
end

RSpec.shared_examples 'sibling_collections_viewable_by_user' do

  it 'sibling_collections_viewable_by_user' do
    resource = FactoryGirl.create(resource_type)
    parent_collection = FactoryGirl.create(:collection)
    FactoryGirl.create("collection_#{resource_type}_arc",
                       Hash[resource_type, resource,
                            :collection, parent_collection])
    sibling_collection = FactoryGirl.create(:collection)
    FactoryGirl.create(:collection_collection_arc,
                       parent: parent_collection,
                       child: sibling_collection)
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:collection_user_permission,
                       collection: sibling_collection,
                       user: user,
                       get_metadata_and_previews: true)

    expect(resource.sibling_collections_viewable_by_user(user))
      .to include sibling_collection
  end

end

RSpec.shared_examples 'parent_collections_viewable_by_user' do

  it 'parent_collections_viewable_by_user' do
    resource = FactoryGirl.create(resource_type)
    parent_collection = FactoryGirl.create(:collection)
    FactoryGirl.create("collection_#{resource_type}_arc",
                       Hash[resource_type, resource,
                            :collection, parent_collection])
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:collection_user_permission,
                       collection: parent_collection,
                       user: user,
                       get_metadata_and_previews: true)

    expect(resource.parent_collections_viewable_by_user(user))
      .to include parent_collection
  end

end
