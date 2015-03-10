require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::FilterSets::FilterSetPermissionsShow do
  it_can_be 'dumped' do
    user = FactoryGirl.create(:user)
    filter_set = FactoryGirl.create(:filter_set,
                                    responsible_user: user)
    filter_set.user_permissions << \
      FactoryGirl.create(:filter_set_user_permission)
    filter_set.group_permissions << \
      FactoryGirl.create(:filter_set_group_permission)
    filter_set.api_client_permissions << \
      FactoryGirl.create(:filter_set_api_client_permission)

    let(:presenter) { described_class.new(filter_set, user) }
  end
end
