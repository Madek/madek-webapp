require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'pre_cache_user_data' do

  it 'does not raise ' do

    user = User.find_by_login('adam')
    expect(user).to be

    expect do
      Madek::UserPrecaching.pre_cache_user_data user
    end.not_to raise_error

  end

end
