require 'spec_helper'

describe MediaSetsController do

  context "API Tests" do

    before :all do
      @media_set = Factory(:media_set, :view => true)
      AppSettings.splashscreen_slideshow_set_id = @media_set.id
    end

    context "a not logged-in user" do

      context  "accesses splashscreen"  do

        let(:get_params) do
          {:id => @media_set.id, :format => :json, :with => {:media_set => {:media_entries => {:author => true, :title => true, :image => {:size => "large"}}}}}
        end

        it  "should not redirect" do
          get :show, get_params
          response.body.should_not match /redirected/
        end

        it  "should set the json response data correctly" do
          get :show, get_params
          json = JSON.parse(response.body)
          json["id"].should == @media_set.id
          json["is_set"].should == true
          json["media_entries"].should be
        end
      end

    end

  end

end

