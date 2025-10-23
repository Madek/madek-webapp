require 'spec_helper'

describe GroupsController do
  let(:current_user) { FactoryBot.create :user }
  let(:group) { FactoryBot.create :group, name: 'cool group', institutional_name: 'coolio' }
  let(:unassignable_group) { FactoryBot.create :group, is_assignable: false, name: 'noli me tangere' }
  before(:example) do
    5.times { FactoryBot.create :group }
  end

  context 'Resource: Groups - responds to search with json' do
    it 'filtering with params[:search_term] by name' do
      get :index,
          params: {
            search_term: group.name,
            format: :json },
          session: { user_id: current_user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['name']).to be == group.name
    end

    it 'filtering with params[:search_term] by institutional name' do
      get :index,
          params: {
            search_term: group.institutional_name,
            format: :json },
          session: { user_id: current_user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['name']).to be == group.name
    end

    it 'does not return an unassignable group' do
      get :index,
          params: {
            search_term: unassignable_group.name,
            format: :json },
          session: { user_id: current_user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 0
    end
  end
end
