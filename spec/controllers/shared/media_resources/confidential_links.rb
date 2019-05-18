RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_handles_properly, 'it handles properly'
end

shared_examples 'confidential urls' do

  %w(show_by_confidential_link show).each do |action_name|
    describe "action: #{action_name}" do
      it 'renders template' do
        cf_link = create :confidential_link, user: @user, resource: resource

        get action_name,
            params: confidential_link_params(action_name, cf_link.token)

        expect(response).to be_success
        expect(response).to render_template(action_name)
      end

      context 'when token is invalid' do
        it 'raises unauthorized error' do
          fake_token = 'ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEF'
          expect do
            get(action_name,
                params: confidential_link_params(action_name, fake_token))
          end
            .to raise_error(Errors::UnauthorizedError)
        end
      end

      context 'when token is revoked' do
        it 'raises unauthorized error' do
          cf_link = create :confidential_link, user: @user, resource: resource,
                                               revoked: true

          expect do
            get(action_name,
                params: confidential_link_params(action_name, cf_link.token))
          end
            .to raise_error(Errors::UnauthorizedError)
        end
      end

      context 'when token has expired' do
        it 'raises unauthorized error' do
          cf_link = create(:confidential_link,
                           user: @user,
                           resource: resource,
                           expires_at: 1.second.from_now)
          cf_link.reload

          sleep 1

          expect do
            get(action_name,
                params: confidential_link_params(action_name, cf_link.token))
          end
            .to raise_error(Errors::UnauthorizedError)
        end
      end
    end
  end

  describe 'action: confidential_links' do
    before do
      if resource.respond_to?(:is_published)
        resource.update_column(:is_published, true)
      end
    end

    context 'when resource is published' do
      context 'when user is an owner' do
        it 'renders template' do
          get :confidential_links,
              params: { id: resource.id },
              session: { user_id: @user.id }

          expect(response).to be_success
          expect(response).to render_template :confidential_links
        end
      end

      context 'when logged in user is not an owner' do
        it 'raises forbidden error' do
          resource.update_column(:responsible_user_id, create(:user).id)

          expect do
            get :confidential_links,
                params: { id: resource.id },
                session: { user_id: @user.id }
          end.to raise_error Errors::ForbiddenError
        end
      end
    end
  end

  def confidential_link_params(action_name, token)
    token_param =
      case action_name
      when 'show' then { access: token }
      when 'show_by_confidential_link' then { token: token }
      end

    { id: resource.id }.merge(token_param)
  end
end
