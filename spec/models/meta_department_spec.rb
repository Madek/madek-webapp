require 'spec_helper'

describe MetaDepartment do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_department}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_department).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_department).should be_persisted
    end

    it "should have the correct type " do
      (FactoryGirl.create :meta_department).reload.type.should == MetaDepartment.name
    end

  end

end



