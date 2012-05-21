require 'spec_helper'

describe MetaDatumDate do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_date}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_date).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_date).should be_persisted
    end

  end

end


