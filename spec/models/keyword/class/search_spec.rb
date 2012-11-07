require 'spec_helper'

describe Keyword do

  before :all do
    3.times do
      FactoryGirl.create :keyword
    end
  end

  describe "class methods" do

    context "search" do
      it "finds existing resources" do
        string = Keyword.first.to_s
        Keyword.search(string).count.should >= 1
      end
      
      it "prevents sql injection" do
        string = "string ' with quotes"
        Keyword.search(string).count.should == 0
      end
    end

  end
end