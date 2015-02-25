RSpec.configure do |c|
  c.alias_it_should_behave_like_to \
    :it_assigns_according_to,
    'assigns according to'
end

RSpec.shared_examples 'filter' do |filter|

  it filter do
    get :index, Hash[filter, 'true'], user_id: user.id

    assert_response :success
    records = assigns(model.model_name.plural.to_sym)
    expect(records).to be
    expect(records.count).to be == 1
  end

end
