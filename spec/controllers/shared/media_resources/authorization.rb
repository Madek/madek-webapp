RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_performs, 'it performs'
end

RSpec.shared_examples 'authorization' do

  let(:model_name) do
    described_class.controller_name.classify.constantize.model_name
  end

  it 'public resource' do
    resource = FactoryGirl.create(model_name.singular,
                                  get_metadata_and_previews: true)
    get :show, params: { id: resource.id }
    assert_response 200
  end

  it 'not public resource' do
    resource = FactoryGirl.create(model_name.singular,
                                  get_metadata_and_previews: false)
    expect { get :show, params: { id: resource.id } }
      .to raise_error Errors::UnauthorizedError
  end

  it 'resource with user permission' do
    resource = FactoryGirl.create(model_name.singular,
                                  get_metadata_and_previews: false)
    resource.user_permissions << \
      FactoryGirl.create("#{model_name.singular}_user_permission",
                         Hash[model_name.singular, resource])

    user = FactoryGirl.create :user
    expect { get :show, params: { id: resource.id }, session: { user_id: user.id } }
      .to raise_error Errors::ForbiddenError
  end

end
