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

  describe "setting the value" do

    before :each do
      @mdd = (FactoryGirl.create :meta_datum_date, meta_date_from: nil, meta_date_to: nil)
    end

    describe "setting free text" do

      it "should not raise an error" do
        expect{ @mdd.value= "18Jhd"}.not_to raise_error
      end

    end

    it "should not raise an error" do
      expect{ @mdd.value= "2012-05-22"}.not_to raise_error
    end

    describe "setting single year" do
      before :each do
        @mdd.value= "2012-05-22"
        @mdd.reload
      end

      it "should have a meta_date_from field" do
        @mdd.meta_date_from.should_not be_nil
      end

    end

    describe "setting from year to year " do

      before :each do
        @mdd.value= "2012-05-22 - 2012-05-23"
        @mdd.reload
      end

      it "should have a meta_date_from field" do
        @mdd.meta_date_from.should_not be_nil
      end

      it "should have a meta_date_to field" do
        @mdd.meta_date_to.should_not be_nil
      end

    end

  end

end


