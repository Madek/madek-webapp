require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Vocabularies::VocabularyPermissionsShow do
  it_can_be 'dumped' do
    current_user = FactoryGirl.create(:user)
    vocabulary = FactoryGirl.create(:vocabulary, enabled_for_public_use: false)

    vocabulary.user_permissions << \
      FactoryGirl.create(:vocabulary_user_permission)
    vocabulary.group_permissions << \
      FactoryGirl.create(:vocabulary_group_permission)
    vocabulary.api_client_permissions << \
      FactoryGirl.create(:vocabulary_api_client_permission)

    let(:presenter) { described_class.new(vocabulary, current_user) }
  end
end
