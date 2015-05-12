require 'spec_helper'

describe PeopleController do
  it 'responds to search with json' do
    user = FactoryGirl.create :user
    2.times { FactoryGirl.create :user }
    person = Person.first

    get :index, { search_term: person.first_name, format: :json },
        user_id: user.id

    assert_response :success
    expect(response.content_type).to be == 'application/json'
    result = JSON.parse(response.body)['result']
    expect(result.size).to be == 1
    expect(result.first['name']).to match /#{person.first_name}/
  end
end
