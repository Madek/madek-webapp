require 'spec_helper'

describe MediaResource do

  before :all do
    3.times do
      FactoryGirl.create :media_set_with_title
    end
  end

  describe "class methods" do

    context "search" do
      it "finds existing resources" do
        string = MediaResource.first.title.split.first
        MediaResource.search(string).count.should >= 1
      end
      
      it "prevents sql injection" do
        string = "string ' with quotes"
        lambda {MediaResource.search(string)}.should_not raise_error
        #MediaResource.search(string).count.should == 0
      end
    end

  end
end