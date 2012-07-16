require 'spec_helper'

describe GraphQueries do

  before :all do

    #
    #
    # 1 -> 11 -> 111
    #   -> 12 -> 121 
    #
    # 1 -> 21
    #

    @owner = FactoryGirl.create :user
    @viewer = FactoryGirl.create :user

    @top_set1 = FactoryGirl.create :media_set, user: @owner
    @top_set1.children << (@child_11 = FactoryGirl.create :media_set, user: @owner)
    @top_set1.children << (@child_12 = FactoryGirl.create :media_set, user: @owner)

    @child_11.children << (@child_111 = FactoryGirl.create :media_set, user: @owner)
    @child_12.children << (@child_121 = FactoryGirl.create :media_resource, user: @owner)

    @top_set2 = FactoryGirl.create :media_set, user: @owner
    @top_set2.children << (@child_21 = FactoryGirl.create :media_set, user: @owner)

  end

  describe "Computing all reachable arcs of a Set" do
    describe "top_set1" do
      it "should have 4 reachable arcs" do
        GraphQueries.reachable_arcs(@top_set1).size.should == 4
      end
    end
  end

  describe "Computing all the descendants of" do

    describe "top_set1" do

      it "should have 4 children" do
        GraphQueries.descendants(@top_set1).size.should == 4
      end

      describe "scoped by accessible resources of a viewer" do
        context "the view can view top_set1 and resource 121" do

          before :each do
            FactoryGirl.create :userpermission, user: @viewer, media_resource: @top_set1, view: true
            FactoryGirl.create :userpermission, user: @viewer, media_resource: @child_121, view: true
          end

          it "should excatly contain the one descendant" do
            descendants = GraphQueries.descendants(@top_set1).accessible_by_user(@viewer)
            descendants.size.should == 1
            descendants.should include(@child_121)
          end

        end
      end
    end


  end

end

