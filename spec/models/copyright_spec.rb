require 'spec_helper'

describe Copyright do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :copyright}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :copyright).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :copyright).should be_persisted
    end

  end


end


