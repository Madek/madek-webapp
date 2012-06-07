require 'spec_helper'

describe MediaResource do


  context "there exists resources"  do

    before :all do
      @media_entry = FactoryGirl.create :media_entry
      @media_set_parent =  FactoryGirl.create :media_set
      @media_set_child =  FactoryGirl.create :media_set
    end

    context "relationships" do
      
      it "should be possible to add a media_entry as a child to media_set" do
        expect {@media_set_parent.media_entries << @media_entry}.not_to raise_error 
      end
  
      context "a media_set has a media_entry as child " do
        before :each do
          @media_set_parent.media_entries << @media_entry
        end
  
        it "should be included in the media_entries of the set" do
          @media_set_parent.media_entries.should include @media_entry
        end
  
        it "the media_set should be included in the parents of the media_entry" do
          @media_entry.parents.should include @media_set_parent
        end
      end
      
      it "should be possible to add a media_sets to the child_sets of a media_set " do
        expect { @media_set_parent.child_sets << @media_set_child }.not_to raise_error
      end
  
      context "a media_set has a media_set as child " do
        before :each do
          @media_set_parent.child_sets << @media_set_child
        end
  
        it "should be included in the child_sets of the parents " do
          @media_set_parent.child_sets.should include @media_set_child
        end
  
        it "the media_set_parent should be included in the parents of the media_set_child" do
          @media_set_child.parents.should include @media_set_parent
        end
      end

    end

    context "meta_data" do

      before :all do
        pending # Thomas working here
        #@media_entry.update_attributes({:meta_data_attributes => {"0" => {:meta_key_label => "author", :value => "Pablo Picasso"}}})
      end
      
      it "exports person meta_data as string for exiftool, not as ruby object" do
        pending # Thomas working here
        #s = @media_entry.send :to_metadata_tags
        #s.include?("-XMP-madek:Author='Picasso, Pablo'").should be_true
        #s.include?("#<").should be_false
      end
      
    end

    ####### INTERNAL Permissions

    context "internal permissions"  do


      before :all do
        # DataFactory.create_small_dataset
        @media_resource = FactoryGirl.create :media_resource, view: false
        @user = FactoryGirl.create :user
      end

      context "function userpermission_disallows" do

        it "should return not nil if there is a userpermission that disallows" do
          FactoryGirl.create :userpermission, view: false, user: @user, media_resource: @media_resource
          @media_resource.userpermissions.disallows(@user, :view).should_not == nil
        end

        it "should return nil if there is no userpermission that disallows" do
          @media_resource.userpermissions.disallows(@user, :view).should == nil
        end


      end

      context "function userpermission_allows " do

        it "should return not nil if there is a userpermission that allows " do
          FactoryGirl.create :userpermission, view: true, user: @user, media_resource: @media_resource
          @media_resource.userpermissions.allows(@user, :view).should_not == nil
        end

        it "should return nil if there is no userpermission that allows " do
          @media_resource.userpermissions.allows(@user, :view).should == nil
        end

      end

      context "function grouppermission_allows" do

        before :each do
          @group = FactoryGirl.create :group
          @group.users << @user
        end

        it "should return nil if there is no grouppermission at all" do
          @media_resource.grouppermissions.allows(@user, :view).should == nil
        end


        it "should return nil if there is a grouppermission that does not allow " do
          FactoryGirl.create :grouppermission, view: false, group: @group, media_resource: @media_resource
          @media_resource.grouppermissions.allows(@user, :view).should == nil
        end


        it "should return not nil if there is a grouppermission that allows " do
          FactoryGirl.create :grouppermission, view: true, group: @group, media_resource: @media_resource
          @media_resource.grouppermissions.allows(@user, :view).should_not == nil
        end


      end

    end

  end


  context "public permissions" do

    describe "A public viewable MediaResource" do

      before(:each) do
        @owner = FactoryGirl.create :user
        @media_resource = FactoryGirl.create :media_resource, user: @owner, view: true
        @user = FactoryGirl.create :user
      end

      it "should be included in the users viewable media_resources" do
        (MediaResource.accessible_by_user @user, :view).should include @media_resource
      end

      context "the user is not allowed by user permissions" do

        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: false
        end

        it "should be included in the users viewable media_resources" do
          (MediaResource.accessible_by_user @user, :view).should include @media_resource
        end

      end
    end


    describe "A non public viewable MediaResource" do 

      before(:each) do
        @owner = FactoryGirl.create :user
        @media_resource = FactoryGirl.create :media_resource, user: @owner, view: false
        @user = FactoryGirl.create :user
      end

      it "should be included in the owners viewable media_resources" do
        (MediaResource.accessible_by_user @owner, :view).should include @media_resource
      end

      it "should be included in the viewable_media_resources even if the owner is disallowed by media_resourceuserpermissions"  do
        FactoryGirl.create :userpermission, user: @owner, media_resource: @media_resource, view: false
        (MediaResource.accessible_by_user @owner, :view).should include @media_resource
      end


      it "should not be included for an user without any permissions" do
        (MediaResource.accessible_by_user @user, :view).should_not include @media_resource
      end

      context "when a userpermission allows the user" do

        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: true
        end

        it "the media_resource should be included" do
          (MediaResource.accessible_by_user @user, :view).should include @media_resource
        end

      end

      context "a mediaresourcegrouppermission allows the user to view" do

        before(:each) do
          @group = FactoryGirl.create :group
          @group.users << @user
          FactoryGirl.create :grouppermission, view: true, group: @group, media_resource: @media_resource
        end

        it "should be be included for the user" do
          (MediaResource.accessible_by_user @user, :view).should include @media_resource
        end

        context "when a mediaresourceuserpermission denies the user to view" do
          before(:each) do
            FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: false
          end

          it "should not be included for the user" do
            (MediaResource.accessible_by_user @user, :view).should_not include @media_resource
          end
        end
      end
    end
  end
end


