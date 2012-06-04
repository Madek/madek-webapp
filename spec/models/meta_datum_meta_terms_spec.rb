require 'spec_helper'

describe MetaDatumMetaTerms do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_meta_terms}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_meta_terms).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_meta_terms).should be_persisted
    end

  end

  describe "Linking with MetaTerms" do

    before :each do
      @mdd = FactoryGirl.create :meta_datum_meta_terms
      @meta_term1 = FactoryGirl.create :meta_term
      @meta_term2 = FactoryGirl.create :meta_term
    end

    it "should be possible to add a term w.o. error" do
      expect{@mdd.meta_terms << @meta_term1}.not_to raise_error
    end

    context "added relations" do 

      before :each do
        @mdd.meta_terms << @meta_term1
        @mdd.meta_terms<< @meta_term2
      end

      it "should have persist added relations" do
        MetaDatumMetaTerms.find(@mdd.id).meta_terms.should include @meta_term1
        MetaDatumMetaTerms.find(@mdd.id).meta_terms.should include @meta_term2
      end

      describe "value interface" do
        it "should be an alias for people" do
          MetaDatumMetaTerms.find(@mdd.id).value.should include @meta_term1
          MetaDatumMetaTerms.find(@mdd.id).value.should include @meta_term2
        end

      end

    end

  end

end

