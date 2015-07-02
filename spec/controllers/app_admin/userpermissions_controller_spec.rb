require 'spec_helper'

describe AppAdmin::UserpermissionsController do
  include Controllers::Shared

  let(:admin) { create :admin, login: 'admin' }
  let(:user) { create :user }

  describe '#new' do
    let(:media_set) { create :media_set, user: admin }
    before { get :new, { media_set_id: media_set.id }, valid_session(admin) }

    it 'responds with success' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns variables correctly' do
      expect(assigns[:userpermission]).to be_an_instance_of(Userpermission)
      expect(assigns[:media_set]).to eq media_set
    end

    it "renders 'new' template" do
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    let(:media_set) { create :media_set_with_children }
    let(:userpermission_params) do
      {
        userpermission: {
          view: '1',
          edit: '0',
          download: '0',
          manage: '1'
        },
        children_media_entries: {
          view: '1',
          edit: '0',
          download: '0',
          manage: '1'
        },
        children_media_sets: {
          view: '1',
          edit: '0',
          download: '0',
          manage: '1'
        }
      }
    end

    def do_post
      post(
        :create,
        {
          media_resource_id: media_set.id,
          user_id: user.id
        }.merge(userpermission_params),
        valid_session(admin)
      )
    end

    it 'redirects to admin media set path' do
      do_post

      expect(response).to redirect_to(app_admin_media_set_path(media_set))
    end

    it 'calls PermissionMaker service' do
      expect(PermissionMaker).to receive(:new)
                                 .with(media_set, user, userpermission_params)
                                 .and_call_original
      expect_any_instance_of(PermissionMaker).to receive(:call)

      do_post
    end
  end
end
