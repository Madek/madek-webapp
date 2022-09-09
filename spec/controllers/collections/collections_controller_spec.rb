require 'spec_helper'
require Rails.root.join 'spec',
                        'controllers',
                        'shared',
                        'media_resources',
                        'authorization.rb'

describe CollectionsController do
  it_performs 'authorization'

  before :example do
    @user = create(:user)
    @coll = create(:collection)
    @coll.user_permissions << create(:collection_user_permission,
                                     user: @user,
                                     get_metadata_and_previews: true,
                                     edit_metadata_and_relations: true)
  end

  it 'updates cover' do
    me = create(:media_entry)
    @coll.media_entries << me

    put :update_cover,
        params: {
          id: @coll.id,
          selected_resource: me.id },
        session: { user_id: @user.id }

    expect(response).to be_redirect
    @coll.reload
    expect(@coll.cover).to be == me
  end

  context 'hightlights' do

    it 'updates successfully' do
      me = create(:media_entry)
      @coll.media_entries << me
      me_h = create(:media_entry)
      @coll.highlighted_media_entries << me_h
      me_h_2 = create(:media_entry)
      @coll.highlighted_media_entries << me_h_2

      child_coll = create(:collection)
      @coll.collections << child_coll

      # highlighted resources before:
      # media_entries: [me_h, me_h_2]
      # collections: []

      put :update_highlights,
          params: {
            id: @coll.id,
            resource_selections: [
              {
                id: me.id,
                type: 'MediaEntry',
                selected: true
              }, {
                id: me_h.id,
                type: 'MediaEntry',
                selected: true
              }, {
                id: me_h_2.id,
                type: 'MediaEntry',
                selected: false
              }, {
                id: child_coll.id,
                type: 'Collection',
                selected: true
              }] },
          session: { user_id: @user.id }

      # highlighted resources after:
      # media_entries: [me, me_h]
      # collections: [child_coll]

      expect(response).to be_redirect
      @coll.reload
      expect(@coll.highlighted_media_entries).to include me
      expect(@coll.highlighted_media_entries).to include me_h
      expect(@coll.highlighted_media_entries).not_to include me_h_2
      expect(@coll.highlighted_collections).to include child_coll
    end

    it 'raises if resource not in arcs' do
      me = create(:media_entry)
      me_h = create(:media_entry)
      @coll.highlighted_media_entries << me_h

      expect do
        put :update_highlights,
            params: {
              id: @coll.id,
              resource_selections: [
                {
                  id: me_h.id,
                  type: 'MediaEntry',
                  selected: false
                }, {
                  id: me.id,
                  type: 'MediaEntry',
                  selected: true
                }] },
            session: { user_id: @user.id }
      end.to raise_error ActiveRecord::RecordNotFound

      @coll.reload
      # due to transaction abort the highlighted media_entries remain as is
      expect(@coll.highlighted_media_entries).not_to include me
      expect(@coll.highlighted_media_entries).to include me_h
    end
  end

  describe '#create' do
    let(:user) { create(:user) }
    before(:all) do
      with_disabled_triggers do
        MetaKey.find_by(id: 'madek_core:title') || create(:meta_key_core_title)
      end
    end

    context 'when there was passed parent_id param' do
      let(:perform_request) do
        post :create,
             params: { collection_title: 'Nested Collection Title', parent_id: parent_id },
             session: { user_id: user.id },
             format: :json
      end

      context 'and was valid' do
        context 'and user has access to it' do
          let(:parent_id) do
            collection = create(:collection, responsible_user: user)
            collection.id
          end

          before { perform_request }

          it 'returns 200 status code' do
            expect(response.status).to eq(200)
          end

          it 'responds with forward_url corresponding to parent collection' do
            expect(JSON.parse(response.body))
              .to eq('forward_url' => collection_path(parent_id))
          end
        end

        context 'and user has no access to it' do
          let(:parent_id) do
            collection = create(:collection)
            collection.id
          end

          it 'raises error' do
            expect { perform_request }.to raise_error(Errors::ForbiddenError)
          end
        end
      end

      context 'and was invalid' do
        let(:parent_id) { :invalid_parent_id }

        before { perform_request }

        it 'returns 200 status code' do
          expect(response.status).to eq(200)
        end

        it 'responds with forward_url corresponding to just created collection' do
          new_collection = user.responsible_collections.first!

          expect(JSON.parse(response.body))
            .to eq('forward_url' => collection_path(new_collection.id))
        end
      end
    end

    context 'when there was no passed parent_id' do
      let(:perform_request) do
        post :create,
             params: { collection_title: 'New Collection' },
             session: { user_id: user.id },
             format: :json
      end

      before { perform_request }

      it 'returns 200 status code' do
        expect(response.status).to eq(200)
      end

      it 'responds with forward_url corresponding to just created collection' do
        new_collection = user.responsible_collections.first!

        expect(new_collection.title).to eq('New Collection')
        expect(JSON.parse(response.body))
          .to eq('forward_url' => collection_path(new_collection.id))
      end
    end
  end
end
