require 'spec_helper'
require 'pry'

describe MediaSetsController do
  include Controllers::Shared
  render_views

  before :each do
    FactoryGirl.create :usage_term
    FactoryGirl.create :context_core
  end

  context "API Tests" do

    before :each do
      @user = FactoryGirl.create :user
    end


    context "a user without session" do

      before :each do
        @media_set = FactoryGirl.create :media_set, view: true, user: @user
        AppSettings.create id: 0, teaser_set_id: @media_set.id
      end


      context  "accesses splashscreen"  do

        let(:get_params) do
          {id: @media_set.id, format: :json, with: {children: true, meta_data:{conetxt_ids: ["core"]}, image: {size: "large"}}}
        end

        it  "should not redirect" do
          get :show, get_params
          expect(response.body).not_to match /redirected/
        end

        it  "should set the json response data correctly" do
          get :show, get_params
          json = JSON.parse(response.body)
          expect(json["id"]).to be== @media_set.id
          expect(json["type"]).to be== "media_set"
          expect(json["children"]).to be
        end
      end
    end



    context "a user with a session and user_id in that session" do 

      before :each do
        (1..5).each do
          @parent_media_set.child_media_resources << (FactoryGirl.create :media_entry, view: true, user: @user)
          media_set = FactoryGirl.create  :media_set, view: true, user: @user
          media_set.child_media_resources << (FactoryGirl.create  :media_entry, view: true, user: @user)
          parent_media_set.child_media_resources << media_set
        end

        context "when i get a set with nested resources, the json response"  do

          let :json_body do
            get_params= {id: @parent_media_set.id, format: :json, with: {media_set: {media_resources: {type: 1, image: {as: "base64", size: "small"}}}}} 
            get :show, get_params, valid_session(@user)
            JSON.parse(response.body)
          end

          it "should contain the correct id" do
            expect(json_body["id"]).to be== @parent_media_set.id
          end

          it  "should have the right sum of contained resources"  do
            summed_sizes = @parent_media_set.child_media_resources.media_entries.size + @parent_media_set.child_media_resources.media_sets.size
            expect(@parent_media_set.child_media_resources.size).to be== summed_sizes
            expect(json_body["media_resources"].size).to be== summed_sizes
          end

          it  "should contain the internal properties of the resource" do 
            json_body["media_resources"].each do |entry|
              expect(entry["id"]).not_to be_blank
              expect(entry["image"]).not_to be_blank
              expect(entry["type"]).not_to be_blank
            end
          end
        end

      end

    end

  end

end

