require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Collections::CollectionPermissions do
  it_can_be 'dumped' do
    user = FactoryBot.create(:user)
    collection = FactoryBot.create(:collection,
                                    responsible_user: user)
    collection.user_permissions << \
      FactoryBot.create(:collection_user_permission)
    collection.group_permissions << \
      FactoryBot.create(:collection_group_permission)
    collection.api_client_permissions << \
      FactoryBot.create(:collection_api_client_permission)

    let(:presenter) { described_class.new(collection, user) }
  end
end
