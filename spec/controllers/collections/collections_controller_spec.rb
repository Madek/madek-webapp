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

      fs = create(:filter_set)
      @coll.filter_sets << fs

      # highlighted resources before:
      # media_entries: [me_h, me_h_2]
      # collections: []
      # filter_sets: []

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
              }, {
                id: fs.id,
                type: 'FilterSet',
                selected: true
              }] },
          session: { user_id: @user.id }

      # highlighted resources after:
      # media_entries: [me, me_h]
      # collections: [child_coll]
      # filter_sets: [fs]

      expect(response).to be_redirect
      @coll.reload
      expect(@coll.highlighted_media_entries).to include me
      expect(@coll.highlighted_media_entries).to include me_h
      expect(@coll.highlighted_media_entries).not_to include me_h_2
      expect(@coll.highlighted_collections).to include child_coll
      expect(@coll.highlighted_filter_sets).to include fs
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
end
