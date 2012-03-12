require 'spec_helper'

describe MediaResourcesController do
  render_views
  
  before :all do
    @user = FactoryGirl.create :user
  end
  
  context "fetch an index of media resources" do
    before :all do
      # MediaResources
      40.times do
        type = rand > 0.5 ? :media_entry : :media_set
        Factory type, :user => @user
      end
      # MetaContexts
      8.times do
        Factory :meta_context
      end
    end
    
    let :session do
      {:user_id => @user.id}
    end
    
    describe "a plain response" do
      it "should respond only with a collection of id's if there is not more requested" do
        get :index, {format: 'json'}, session
        response.should  be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr.keys.size.should == 1
          mr.keys.first == "id"
        end     
      end
    end
    
    describe "a response with nested meta date" do
      
      describe "through meta contexts" do
        it "should respond with a collection of media resources with nested meta data" do
          get :index, {format: 'json'}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr.keys.size.should == 1
            mr.keys.first == "id"
          end     
        end        
      end
    end
  end
end
