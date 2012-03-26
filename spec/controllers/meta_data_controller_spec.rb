require 'spec_helper'

describe MediaResourcesController do
  render_views


  before :each do
    @user = FactoryGirl.create :user
    @media_resource= FactoryGirl.create :media_set
    @media_resource.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
  end

  let :session do
    {:user_id => @user.id}
  end



end
