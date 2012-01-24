require 'spec_helper'

describe MediaSetArc do

  before :each do
    @set1 = FactoryGirl.create :media_set
    @set2 = FactoryGirl.create :media_set
    @arc = (FactoryGirl.create :media_set_arc, :parent => @set1 , :child => @set2)
  end


  it "should be producible by a factory" do
    (FactoryGirl.create :media_set_arc, :parent => @set1 , :child => (FactoryGirl.create :media_set)).should_not == nil
  end

  context "referential inegrity" do
    
    it "should cause the arc to be deleted if one of either parent/child set is deleted" do
      @set1.destroy
      MediaSetArc.all.should be_empty
    end

  end

  context "sets in sets" do

    context "graph relations" do

      it "the arcs child should be in the child_sets of the parent" do
        @arc.parent.child_sets.should include @arc.child
      end

      it "the arcs parent should be in the parent_sets of the child" do
        @arc.child.parent_sets.should include @arc.parent
      end

      it "should raise an error if a double arc is inserted " do
        ->(){ FactoryGirl.create :media_set_arc, :parent => @set1 , :child => @set2}.should raise_error
      end

      it "should raise an error if a self reference is insteted " do
        ->(){ FactoryGirl.create :media_set_arc, :parent => @set1 , :child => @set1}.should raise_error
      end

    end

    context "rails relations" do

      it "should be appendable " do
        @set3 = FactoryGirl.create :media_set
        ->(){@set1.child_sets << @set3}.should_not raise_error
      end

      it "the set2 should be included in by_media_set" do
        by_ms = MediaResource.by_media_set(@set1)
        by_ms.first.should == @set2
      end

    end

  end

end


