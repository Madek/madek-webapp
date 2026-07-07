require 'spec_helper'

describe 'context view/use permission filtering' do
  before :example do
    @app_setting = AppSetting.first || create(:app_setting)

    @open_context = Context.find_by_id('vcs-open') ||
      create(:context, id: 'vcs-open')
    @locked_context = Context.find_by_id('vcs-locked') ||
      create(:context,
             id: 'vcs-locked',
             enabled_for_public_view: false,
             enabled_for_public_use: false)
    @locked_context.update!(
      enabled_for_public_view: false, enabled_for_public_use: false)

    @permitted_user = create(:user)
    create(:context_user_permission,
           context: @locked_context, user: @permitted_user, view: true, use: true)

    @app_setting.update!(
      contexts_for_entry_extra: [@open_context.id, @locked_context.id],
      contexts_for_entry_edit: [@open_context.id, @locked_context.id]
    )

    @media_entry = create(:media_entry)
  end

  describe Presenters::MetaData::ResourceMetaData do
    def context_ids_for(user)
      described_class.new(@media_entry, user)
        .contexts_for_entry_extra
        .map { |c| c.context.uuid }
    end

    it 'hides a locked context from anonymous/unpermitted users' do
      expect(context_ids_for(nil)).to eq [@open_context.id]
    end

    it 'shows the locked context to a permitted user' do
      expect(context_ids_for(@permitted_user)).to \
        include(@open_context.id, @locked_context.id)
    end
  end

  describe Presenters::MetaData::MetaMetaDataEdit do
    def context_ids_for(user)
      described_class.new(user, MediaEntry, @media_entry)
        .meta_data_edit_context_ids
    end

    it 'excludes a locked context from edit contexts for unpermitted users' do
      other_user = create(:user)
      expect(context_ids_for(other_user)).to eq [@open_context.id]
    end

    it 'includes the locked context for a permitted user' do
      expect(context_ids_for(@permitted_user)).to \
        include(@open_context.id, @locked_context.id)
    end
  end
end
