require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'


describe Presenters::Vocabularies::VocabularyPermissionsShow do
  before :each do
    AppSetting.find_or_create_by(id: 0)
  end

  let :presenter do
    current_user = FactoryBot.create(:user)
    current_user.reload # due the active_until being nil, although default in db

    vocabulary = FactoryBot.create(:vocabulary, enabled_for_public_use: false)

    vocabulary.user_permissions << \
      FactoryBot.create(:vocabulary_user_permission)
    vocabulary.group_permissions << \
      FactoryBot.create(:vocabulary_group_permission)
    vocabulary.api_client_permissions << \
      FactoryBot.create(:vocabulary_api_client_permission)

    described_class.new(vocabulary, current_user)
  end

  include_examples 'dumped'

end
