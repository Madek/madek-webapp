require 'spec_helper'

describe ApiTokensController do
  context 'ApiTokens' do

    let(:user) { FactoryGirl.create :user }

    context 'creates' do
      it 'not ok when not logged in' do
        expect { post(:create_api_token, format: :json) }
          .to raise_error Errors::UnauthorizedError, 'Please log in!'
      end

      it 'ok when logged in, defaults to read-only' do
        new_attrs = {
          description: Faker::Hacker.phrases.sample
        }

        post(
          :create_api_token,
          params: { api_token: new_attrs, format: :json },
          session: { user_id: user.id })

        assert_response :success
        expect(response.content_type).to be == 'application/json'

        token = ApiToken.where(user: user).last
        expect(token.user.id).to eq user.id

        result = JSON.parse(response.body)
        expect(result['type']).to eq 'ApiToken'
        expect(result['secret']).to be_a String
        expect(result['secret'].length).to be_between(31, 32)
        expect(result['description']).to eq new_attrs[:description]
        expect(result['revoked']).to be false
        expect(result['scopes']).to eq ['read']
      end

      it 'can be allowed to write' do
        new_attrs = {
          description: "read'n'write",
          scope_write: true
        }

        post(
          :create_api_token,
          params: { api_token: new_attrs, format: :json },
          session: { user_id: user.id })

        result = JSON.parse(response.body)
        expect(result['scopes']).to eq ['read', 'write']
      end

    end

    context 'update' do
      it 'revokes' do
        token = ApiToken.create(user: user)
        new_attrs = { revoked: true }

        patch(
          :update_api_token,
          params: { api_token: new_attrs, id: token.id, format: :json },
          session: { user_id: user.id })

        token.reload
        expect(token.revoked).to be true

        assert_response :success
        expect(response.content_type).to be == 'application/json'

        result = JSON.parse(response.body)
        expect(result['type']).to eq 'ApiToken'
        expect(result['revoked']).to be true
      end

      it 'can not be edited if revoked' do
        token = ApiToken.create(user: user, revoked: true)
        new_attrs = { revoked: false }

        expect do
          patch(
            :update_api_token,
            params: { api_token: new_attrs, id: token.id, format: :json },
            session: { user_id: user.id })
        end.to \
          raise_error Errors::ForbiddenError, 'Access Denied!'

        token.reload
        expect(token.revoked).to be true
      end

      it 'can not be edited by other users' do
        token = ApiToken.create(user: user)
        another_user = FactoryGirl.create :user
        new_attrs = { revoked: true }

        expect do
          patch(
            :update_api_token,
            params: { api_token: new_attrs, id: token.id, format: :json },
            session: { user_id: another_user.id })
        end.to \
          raise_error Errors::ForbiddenError, 'Access Denied!'

        token.reload
        expect(token.revoked).to be false
      end
    end

  end

end
