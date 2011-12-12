require 'spec_helper'

describe Media::SetArc do

  before :all do
    @set1 = FactoryGirl.create :media_set
    @set2 = FactoryGirl.create :media_set
  end


  it "should be producible by a factory" do
    (FactoryGirl.create :media_set_arc, :parent => @set1 , :child => @set2).should_not == nil
  end

  context "sets in sets" do

    context "graph relations" do

      before :all do
        @arc = (FactoryGirl.create :media_set_arc, :parent => @set1 , :child => @set2)
      end

      it "the arcs child should be in the child_sets of the parent" do
        @arc.parent.child_sets.should include @arc.child
      end

      it "the arcs parent should be in the parent_sets of the child" do
        @arc.child.parent_sets.should include @arc.parent
      end

    end


    context "rails relations" do

      before :all do
        @set1.child_sets << @set2
      end

      it "the set2 should be included in by_media_set" do
        by_ms = MediaResource.by_media_set(@set1)
        by_ms.first.should == @set2
      end

    end

  end

end


