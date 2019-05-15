require 'spec_helper'

describe ConfidentialLinksController do
  let(:user) { create :user }

  describe 'action: new' do
    context 'when resource is a media entry' do
      context 'when logged in user is an owner' do
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'renders template' do
          get :new, params: { id: resource.id }, session: { user_id: user.id }

          expect(response).to be_success
          expect(response)
            .to render_template 'media_entries/new_confidential_link'
        end

        it 'assigns presenter' do
          get :new, params: { id: resource.id }, session: { user_id: user.id }

          expect(assigns[:get]).to be_instance_of(
            Presenters::MediaEntries::MediaEntryConfidentialLinkNew)
        end

        context 'when resource is not publised' do
          it 'raises not found error' do
            resource.update_column(:is_published, false)

            expect do
              get :new, params: { id: resource.id }, session: { user_id: user.id }
            end.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context 'when logged in user is not an owner' do
        let(:not_owner) { create :user }
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'raises forbidden error' do
          expect do
            get(
              :new,
              params: { id: resource.id },
              session: { user_id: not_owner.id })
          end.to raise_error Errors::ForbiddenError
        end
      end

      context 'when no user is not logged in' do
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'raises unauthorized error' do
          expect { get :new, params: { id: resource.id } }
            .to raise_error Errors::UnauthorizedError
        end
      end
    end

  end

  describe 'action: create' do
    context 'when resource is a media entry' do
      context 'when logged in user is an owner' do
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'redirects to confidential urls show action' do
          post :create, params: { id: resource.id }, session: { user_id: user.id }

          expect(response).to have_http_status(302)
          expect(response).to redirect_to confidential_link_media_entry_path(
            resource,
            resource.confidential_links.first,
            just_created: true
          )
        end

        context 'when resource is not publised' do
          it 'raises not found error' do
            resource.update_column(:is_published, false)

            expect do
              post(
                :create,
                params: { id: resource.id },
                session: { user_id: user.id })
            end.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context 'when logged in user is not an owner' do
        let(:not_owner) { create :user }
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'raises forbidden error' do
          expect do
            post(
              :create,
              params: { id: resource.id },
              session: { user_id: not_owner.id })
          end.to raise_error Errors::ForbiddenError
        end
      end

      context 'when no user is not logged in' do
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'raises unauthorized error' do
          expect { post :create, params: { id: resource.id } }
            .to raise_error Errors::UnauthorizedError
        end
      end
    end

  end

  describe 'action: update' do
    context 'when resource is a media entry' do
      let(:confidential_link) do
        create :confidential_link, user: user, resource: resource
      end

      context 'when logged in user is an owner' do
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'redirects to template urls list' do
          patch(
            :update,
            params: { id: resource.id, confidential_link_id: confidential_link.id },
            session: { user_id: user.id })

          expect(response).to redirect_to \
            confidential_links_media_entry_path(resource)
        end

        context 'when resource is not publised' do
          it 'raises not found error' do
            resource.update_column(:is_published, false)

            expect do
              patch :update,
                    params: {
                      id: resource.id,
                      confidential_link_id: confidential_link.id },
                    session: { user_id: user.id }
            end.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end

      context 'when logged in user is not an owner' do
        let(:not_owner) { create :user }
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'raises forbidden error' do
          expect do
            patch :update,
                  params: {
                    id: resource.id,
                    confidential_link_id: confidential_link.id },
                  session: { user_id: not_owner.id }
          end.to raise_error Errors::ForbiddenError
        end
      end

      context 'when no user is not logged in' do
        let(:resource) do
          create :media_entry_with_image_media_file,
                 creator: user, responsible_user: user
        end

        it 'raises unauthorized error' do
          expect do
            patch :update,
                  params: {
                    id: resource.id,
                    confidential_link_id: confidential_link.id }
          end.to raise_error Errors::UnauthorizedError
        end
      end
    end

  end
end
