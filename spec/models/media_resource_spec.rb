require 'spec_helper'

describe MediaResource do


  context "there exists resources"  do

    before :all do
      @media_entry = FactoryGirl.create :media_entry
      @media_set_parent =  FactoryGirl.create :media_set
      @media_set_child =  FactoryGirl.create :media_set
    end

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

end


