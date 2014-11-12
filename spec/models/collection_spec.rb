require 'spec_helper'

describe Collection do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :collection}.not_to raise_error
    end

  end

  context "an existing Collection" do

    before :each do 
      @collection = FactoryGirl.create :collection
    end


  end

end
