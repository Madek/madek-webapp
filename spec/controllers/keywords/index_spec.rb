require 'spec_helper'

describe KeywordsController do
  include Controllers::Shared
  render_views
  
  before :each do 
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    @keyword1 = FactoryGirl.create :keyword, user: @user
    @keyword2 = FactoryGirl.create :keyword, user: @user
  end

  describe "GET index" do
    context "as JSON" do

      it "should find all keywords" do
        get :index, {format: :json}, valid_session(@user)
        json = JSON.parse(response.body)
        expected = Keyword.all.map {|x| {"id" => x.keyword_term_id, "label" => x.to_s}}
        expect( (json | expected).eql?(json & expected) ).to be true
      end

      it "should find matching keywords" do
        get :index, {format: :json, query: @keyword1.to_s}, valid_session(@user)
        json = JSON.parse(response.body)
        expected = [{"id" => @keyword1.keyword_term_id, "label" => @keyword1.to_s}]
        expect( (json | expected).eql?(json & expected) ).to be true
      end
    end
  end

end

