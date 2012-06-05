require 'spec_helper'

describe MetaDatumCopyright do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_copyright}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_copyright).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_copyright).should be_persisted
    end

  end

  describe "Linking with Copyright" do

    before :each do
      @md = FactoryGirl.create :meta_datum_copyright
      @copyright1 = FactoryGirl.create :copyright
    end

    it "should be possible to set a copyright w.o. error" do
      expect{@md.copyright = @copyright1}.not_to raise_error
    end

    context "added relations" do 

      before :each do
        @md.update_attributes copyright: @copyright1
      end

      it "should have persisted added relations" do
        MetaDatumCopyright.find(@md.id).copyright.should == @copyright1
      end

      describe "value interface" do
        it "should be an alias for copyright" do
          MetaDatumCopyright.find(@md.id).value.should == @copyright1
        end

      end

    end

  end

end

