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
        mr = Factory type, :user => @user
        mr.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
      end
      # MetaContext
      @meta_context = MetaContext.first
    end
    
    let :session do
      {:user_id => @user.id}
    end
    
    let :ids do
      MediaResource.all.shuffle[1..3].map(&:id)
    end
    
    describe "a plain response" do
      it "should respond only with a collection of id's if there is not more requested" do
        get :index, {format: 'json'}, session
        response.should be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr.keys.size.should == 1
          mr.keys.first == "id"
        end     
      end
    end
    
    describe "a response with nested meta date" do
      
      describe "through meta contexts" do
        it "should respond with a collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', with: {meta_data: {meta_context_names: [@meta_context.name]}}}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].keys.should == @meta_context.meta_keys.map(&:label)       
          end
        end        
      end
      
      describe "through meta contexts with a collection of provided ids" do
        it "should respond with the requested collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids, with: {meta_data: {meta_context_names: [@meta_context.name]}}}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].keys.should == @meta_context.meta_keys.map(&:label)       
          end
        end        
      end
      
      describe "through meta contexts with a single id provided" do
        it "should respond with the requested collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids[0,1], with: {meta_data: {meta_context_names: [@meta_context.name]}}}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].keys.should == @meta_context.meta_keys.map(&:label)       
          end
        end        
      end
    end
  end
end
