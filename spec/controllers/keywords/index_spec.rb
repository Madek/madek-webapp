require 'spec_helper'

describe KeywordsController do
  render_views
  
  before :all do 
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    @keyword1 = FactoryGirl.create :keyword, user: @user
    @keyword2 = FactoryGirl.create :keyword, user: @user
  end

  let :session do
    {user_id: @user.id}
  end

  describe "GET index" do
    context "as JSON" do

      it "should find all keywords" do
        get :index, {format: :json}, session
        json = JSON.parse(response.body)
        expected = Keyword.all.map {|x| {"id" => x.meta_term_id, "label" => x.to_s}}
        (json | expected).eql?(json & expected).should be_true
      end

      it "should find matching keywords" do
        get :index, {format: :json, query: @keyword1.to_s}, session
        json = JSON.parse(response.body)
        expected = [{"id" => @keyword1.meta_term_id, "label" => @keyword1.to_s}]
        (json | expected).eql?(json & expected).should be_true
      end
    end
  end

end

