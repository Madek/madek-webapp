require 'spec_helper'

describe MetaDatum::Text do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_text}.not_to raise_error
    end

    it "should not be nil" do
      expect(FactoryGirl.create :meta_datum_text).to be
    end

    it "should be persisted" do
      expect(FactoryGirl.create :meta_datum_text).to be_persisted
    end

  end

  context "an existing MetaDatumString instance " do

    before :each do
      @mds =  FactoryGirl.create :meta_datum_text, string: "original value"
    end


    describe "the string field" do

      it "should be assignable" do
        expect {@mds.string = "new string value"}.not_to raise_error
      end

      it "should be persisted " do
        @mds.string = "new string value" 
        @mds.save
        expect(@mds.reload.string).to be== "new string value"
      end

      describe "the value alias" do

        it "should be accessible" do
          expect {@mds.value}.not_to raise_error
        end

        it "should be setable and persited" do
          @mds.value = "new string value" 
          @mds.save
          expect(@mds.reload.value).to be== "new string value"
        end

        it "should alias string" do
          @mds.string = "Blah"
          @mds.save
          expect(@mds.reload.value).to be== "Blah"
        end

      end

    end

    describe "the to_s method" do

      it "should return the string value" do
        expect(@mds.to_s).to be== "original value"
      end

    end

  end

end


