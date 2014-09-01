require 'spec_helper'

describe InstitutionalGroup do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :institutional_group}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :institutional_group).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :institutional_group).should be_persisted
    end

    it "should have the correct type " do
      (FactoryGirl.create :institutional_group).reload.type.should == InstitutionalGroup.name
    end

  end

end



