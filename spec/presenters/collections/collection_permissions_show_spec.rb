require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Collections::CollectionPermissions do

  let(:presenter) do
    user = FactoryBot.create(:user)
    collection = FactoryBot.create(:collection,
                                   responsible_user: user)
    collection.user_permissions << \
      FactoryBot.create(:collection_user_permission)
    collection.group_permissions << \
      FactoryBot.create(:collection_group_permission)
    collection.api_client_permissions << \
      FactoryBot.create(:collection_api_client_permission)

    described_class.new(collection, user) 
  end

  include_examples 'dumped'

end
