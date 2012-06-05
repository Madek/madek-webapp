require 'spec_helper'

describe MetaContextsController do
  render_views

  before :all do
    DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
    @user = FactoryGirl.create :user
    @description= FactoryGirl.create :meta_term
    @hint = FactoryGirl.create :meta_term
    @label= FactoryGirl.create :meta_term
    @meta_context= FactoryGirl.create :meta_context
    @meta_key= FactoryGirl.create :meta_key
    @meta_key_definition= FactoryGirl.create :meta_key_definition, meta_context: @meta_context, meta_key: @meta_key,
      label: @label, hint: @hint, description: @description
  end

  let :session do
    {:user_id => @user.id}
  end

  let :req do
    {format: 'json', id: @meta_context.name}
  end
  
  let :req_with_meta_keys do
    req.merge!({:with => {:meta_keys => true}})
  end

  let :get_resp_hash do
    get :show, req, session
    JSON.parse response.body
  end
  
  let :get_resp_hash_with_meta_keys do
    get :show, req_with_meta_keys, session
    JSON.parse response.body
  end

  let :get_first_meta_key_definition do
    get_resp_hash_with_meta_keys["meta_keys"].first
  end


  describe "getting a meta_context" do
 
    it "should be successful"  do 
      get :show , req, session
      response.should be_success
    end

    describe "the response" do

      it "should contain some minimal data (name, label, description)" do
        get :show , req, session
        resp = JSON.parse response.body
        resp["name"].should == @meta_context.name
        resp["label"].should == @meta_context.label.to_s
        resp["description"].should == @meta_context.description.to_s
      end
      
      it "should not contain meta keys when not requested" do
        get :show , req, session
        resp = JSON.parse response.body
        resp["meta_keys"].should == nil
      end
    end
  end
  
  describe "getting a meta_context with nested meta_keys" do
 
    it "should be successful" do 
      get :show, req_with_meta_keys, session
      response.should be_success
    end
    
    describe "the response" do
      
      it "should contain meta_keys" do
        get_resp_hash_with_meta_keys["meta_keys"].should_not be_nil
      end
      
      describe "the first meta_key_definition" do

        it "should have a name" do
          get_first_meta_key_definition["name"].should_not be_nil
        end

        it "should have a label" do
          get_first_meta_key_definition["label"].should_not be_nil
        end

        it "should have a hint" do
          get_first_meta_key_definition["hint"].should_not be_nil
        end
        
        it "should have a description" do
          get_first_meta_key_definition["description"].should_not be_nil
        end
        
        it "should have a type" do
          get_first_meta_key_definition["type"].should_not be_nil
        end
      end
    end
  end

  after :all do
    @meta_key_definition.destroy
    @meta_key.destroy
    @meta_context.destroy
    @description.destroy
    @hint.destroy
    @label.destroy
    @user.destroy
    @user.person.destroy
  end
end


