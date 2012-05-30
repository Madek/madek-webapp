require 'spec_helper'

describe MetaDatumKeywords do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_keywords}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_keywords).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_keywords).should be_persisted
    end

  end

  describe "Linking with MetaDepartements" do

    before :each do
      @mdd = FactoryGirl.create :meta_datum_keywords
      @keyword1 = FactoryGirl.create :keyword
      @keyword2 = FactoryGirl.create :keyword
    end

    it "should be possible to add a department w.o. error" do
      expect{@mdd.keywords << @keyword1}.not_to raise_error
    end

    it "should not be possible to add a plain group as a keyword " do
      expect{@mdd.keywords << (FactoryGirl.create :group)}.to raise_error
    end

    context "added relations" do 

      before :each do
        @mdd.keywords << @keyword1
        @mdd.keywords<< @keyword2
      end

      it "should have persist added relations" do
        MetaDatumKeywords.find(@mdd.id).keywords.should include @keyword1
        MetaDatumKeywords.find(@mdd.id).keywords.should include @keyword2
      end

      describe "value interface" do
        it "should be an alias for people" do
          MetaDatumKeywords.find(@mdd.id).value.should include @keyword1
          MetaDatumKeywords.find(@mdd.id).value.should include @keyword2
        end

      end

    end

  end

end

