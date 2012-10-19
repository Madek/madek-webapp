require 'spec_helper'

describe Person do

  before :all do
    3.times do
      FactoryGirl.create :person
    end
  end

  describe "class methods" do

    context "search" do
      it "finds existing resources" do
        string = Person.first.firstname
        Person.search(string).count.should >= 1
      end
      
      it "prevents sql injection" do
        string = "string ' with quotes"
        Person.search(string).count.should == 0
      end
    end

  end
end