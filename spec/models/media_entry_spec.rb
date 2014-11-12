require 'spec_helper'

describe MediaEntry do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :media_entry}.not_to raise_error
    end

  end

  context "an existing MediaEntry" do

    before :each do 
      @media_entry = FactoryGirl.create :media_entry
    end


  end

end
