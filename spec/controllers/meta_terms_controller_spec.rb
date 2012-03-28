require 'spec_helper'

describe MetaTermsController do
  render_views

  before :all do
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
    {format: 'json',name: @meta_context.name}
  end

  let :get_resp_hash do
    get :context_keys_terms , req, session
    JSON.parse response.body
  end

  let :get_first_meta_key_definition do
    get_resp_hash["meta_key_definitions"].first
  end


  describe "getting meta_terms through context and kye_defintions " do
 
    it "should be successful"  do 
      get :context_keys_terms , req, session
      response.should be_success
    end

    describe "the response " do

      it "should contain the name of the context" do
        get :context_keys_terms , req, session
        resp = JSON.parse response.body
        resp["name"].should == @meta_context.name
      end

      it "should contain meta_key_definitions" do
        get_resp_hash["meta_key_definitions"].should_not be_nil
      end

      describe "the first meta_key_definition" do

        it "should have a label" do
          get_first_meta_key_definition["label"].should_not be_nil
        end

        it "should contain the correct en_gb field " do
          get_first_meta_key_definition["label"]["en_gb"].should == @label.en_gb
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
  end
end

