require 'spec_helper'

describe MetaDatumDate do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_string}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_string).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_string).should be_persisted
    end

  end

  context "an existing MetaDatumString instance " do

    before :each do
      @mds =  FactoryGirl.create :meta_datum_string, string: "original value"
    end


    describe "the string field" do

      it "should be assignable" do
        expect {@mds.string = "new string value"}.not_to raise_error
      end

      it "should be persisted " do
        @mds.string = "new string value" 
        @mds.save
        @mds.reload.string.should == "new string value"
      end

      describe "the value alias" do

        it "should be accessible" do
          expect {@mds.value}.not_to raise_error
        end

        it "should be setable and persited" do
          @mds.value = "new string value" 
          @mds.save
          @mds.reload.value.should == "new string value"
        end

        it "should alias string" do
          @mds.string = "Blah"
          @mds.save
          @mds.reload.value.should == "Blah"
        end

      end

    end

    describe "the to_s method" do

      it "should return the string value" do
        @mds.to_s.should == "original value"
      end

    end

  end

end


