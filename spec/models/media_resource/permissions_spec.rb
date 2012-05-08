require 'spec_helper'

describe MediaResource do

  describe "by_permission_presets_and_user" do

    before :each do
      @owner = FactoryGirl.create :user
      @viewer = FactoryGirl.create :user
      PermissionPreset.destroy_all
      @view_preset = PermissionPreset.create name: "view" , view: true
      @dl_preset = PermissionPreset.create name: "dl" , view: true, download: true

      @ms1 = FactoryGirl.create :media_set, user: @owner
      @ms2 = FactoryGirl.create :media_set, user: @owner

      Userpermission.create media_resource: @ms1, view: true, user: @viewer

      @group = FactoryGirl.create :group
      @group.users << @viewer
      Grouppermission.create media_resource: @ms2, group: @group, view: true, download: true

    end

    it "should be chainable " do
      expect { MediaResource.where(true).where_permission_presets_and_user([@view_preset],@viewer) }.not_to raise_error
    end

    it "should contain exactly the correct resouce if there is a matching userpermission" do
      MediaResource.where_permission_presets_and_user([@view_preset],@viewer).should include @ms1
      MediaResource.where_permission_presets_and_user([@view_preset],@viewer).size.should equal 1

    end

    it "should contain exactly the resouce if there is a matching grouppermission " do
      MediaResource.where_permission_presets_and_user([@dl_preset],@viewer).should include @ms2
      MediaResource.where_permission_presets_and_user([@dl_preset],@viewer).size.should equal 1
    end

    it "should not contain the resouce if there is a matching grouppermission but there is a overwriting userpermission" do
      Userpermission.create media_resource: @ms2, view: true, user: @viewer
      MediaResource.where_permission_presets_and_user([@dl_preset],@viewer).should_not include @ms2
    end

  end

end
