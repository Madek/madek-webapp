require 'spec_helper'

describe Grouppermission do


  describe Grouppermission do

    it "should be producible by a factory" do
      (FactoryGirl.create :grouppermission).should_not == nil
    end

    context "because of data consistency" do

      it "should raise an error if the group is set to null" do
        expect { FactoryGirl.create :grouppermission , :usergroup_id => nil }.to raise_error
      end
      it "should raise an error if the group_id is set to a non existing group" do
        expect { FactoryGirl.create :grouppermission , :usergroup_id => -1 }.to raise_error
      end


      it "should raise an error if the mediaresource is set to null" do
        expect { FactoryGirl.create :grouppermission , :mediaresource_id => nil }.to raise_error
      end
      it "should raise an error if the mediaresource_id is set to a non existing mediaresource" do
        expect { FactoryGirl.create :grouppermission , :mediaresource_id => -1}.to raise_error
      end

    end


    context "referential integrity" do

      before :each do
        @group = FactoryGirl.create :group
        @media_resource = FactoryGirl.create :media_set, :owner => (FactoryGirl.create :user)
      end

      it "should remove grouppermissions if the group is destroyed" do
        id = (FactoryGirl.create :grouppermission, :group => @group, :media_resource => @media_resource).id
        (Grouppermission.find_by_id id).should_not be_nil
        @group.destroy
        (Grouppermission.find_by_id id).should be_nil
      end

      it "should remove grouppermissions if the resource is destroyed" do
        pending "doesn't work with polymorphic relationships"
        #      id = (FactoryGirl.create :grouppermission, :group => @group, :resource => @resource).id
        #      (grouppermission.find_by_id id).should_not be_nil
        #      @resource.destroy
        #      (grouppermission.find_by_id id).should be_nil
      end

    end



  end

end
