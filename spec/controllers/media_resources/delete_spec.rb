require 'spec_helper'

describe MediaResourcesController do
  render_views

  before :all do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :meta_context_core
    @owner = FactoryGirl.create :user
    @user = FactoryGirl.create :user
  end

  describe "HTTP DELETE on one media_resource" do
    before :each do
      @media_resource = FactoryGirl.create :media_entry, user: @owner
    end

    context "by the owner" do
      it "should be successful and delete the media_resource" do
        delete :destroy, {format: "json", id: @media_resource.id}, {user_id: @owner.id} 
        expect(response).to be_success
        expect(MediaResource.where(id: @media_resource.id).first).to be_nil
      end
    end

    context "by some other user" do

      it "should not successful and retain the media_resource" do
        delete :destroy, {format: "json", id: @media_resource.id}, {user_id: @user.id} 
        expect(response).not_to be_success
        expect(MediaResource.where(id: @media_resource.id).first).not_to be_nil
      end


      context "with view permission" do
        before :each do
          Userpermission.create media_resource: @media_resource, user: @user, view: true
        end
        it "should not successful and retain the media_resource" do
          delete :destroy, {format: "json", id: @media_resource.id}, {user_id: @user.id} 
          expect(response).not_to be_success
          expect(MediaResource.where(id: @media_resource.id).first).not_to be_nil
        end
      end
      
      context "with edit permission" do
        before :each do
          Userpermission.create media_resource: @media_resource, user: @user, edit: true
        end
        it "should not successful and retain the media_resource" do
          delete :destroy, {format: "json", id: @media_resource.id}, {user_id: @user.id} 
          expect(response).not_to be_success
          expect(MediaResource.where(id: @media_resource.id).first).not_to be_nil
        end
      end
      
      context "with manage permission" do
        before :each do
          Userpermission.create media_resource: @media_resource, user: @user, manage: true
        end
        it "should not successful and retain the media_resource" do
          delete :destroy, {format: "json", id: @media_resource.id}, {user_id: @user.id} 
          expect(response).not_to be_success
          expect(MediaResource.where(id: @media_resource.id).first).not_to be_nil
        end
      end

    end

  end

end

