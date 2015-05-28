require 'spec_helper'

describe AppAdmin::GrouppermissionsController do
  include Controllers::Shared

  let(:admin) { create :admin, login: 'admin' }
  let(:group) { create :group }

  describe '#new' do
    let(:media_set) { create :media_set, user: admin }
    before { get :new, { media_set_id: media_set.id }, valid_session(admin) }

    it 'responds with success' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns variables correctly' do
      expect(assigns[:grouppermission]).to be_an_instance_of(Grouppermission)
      expect(assigns[:media_set]).to eq media_set
    end

    it "renders 'new' template" do
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    let(:media_set) { create :media_set_with_children }
    let(:grouppermission_params) do
      {
        grouppermission: {
          view: '1',
          edit: '0',
          download: '0'
        },
        children_media_entries: {
          view: '1',
          edit: '0',
          download: '0'
        },
        children_media_sets: {
          view: '1',
          edit: '0',
          download: '0'
        }
      }
    end

    def do_post
      post(
        :create,
        {
          media_resource_id: media_set.id,
          group_id: group.id
        }.merge(grouppermission_params),
        valid_session(admin)
      )
    end

    it 'redirects to admin media set path' do
      do_post

      expect(response).to redirect_to(app_admin_media_set_path(media_set))
    end

    it 'calls PermissionMaker service' do
      expect(PermissionMaker).to receive(:new)
                                 .with(media_set, group, grouppermission_params)
                                 .and_call_original
      expect_any_instance_of(PermissionMaker).to receive(:call)

      do_post
    end
  end
end
