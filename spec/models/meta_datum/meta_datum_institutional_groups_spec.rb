require 'spec_helper'

describe MetaDatumInstitutionalGroups do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_institutional_groups}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_institutional_groups).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_institutional_groups).should be_persisted
    end

  end

  describe "Linking with InstitutionalGroups" do

    before :each do
      @mdd = FactoryGirl.create :meta_datum_institutional_groups
      @institutional_group1 = FactoryGirl.create :institutional_group
      @institutional_group2 = FactoryGirl.create :institutional_group
    end

    it "should be possible to add a department w.o. error" do
      expect{@mdd.institutional_groups << @institutional_group1}.not_to raise_error
    end

    it "should not be possible to add a plain group as a institutional_group " do
      expect{@mdd.institutional_groups << (FactoryGirl.create :group)}.to raise_error
    end

    context "added relations" do 

      before :each do
        @mdd.institutional_groups << @institutional_group1
        @mdd.institutional_groups<< @institutional_group2
      end

      it "should have persist added relations" do
        MetaDatumInstitutionalGroups.find(@mdd.id).institutional_groups.should include @institutional_group1
        MetaDatumInstitutionalGroups.find(@mdd.id).institutional_groups.should include @institutional_group2
      end

      describe "value interface" do
        it "should be an alias for people" do
          MetaDatumInstitutionalGroups.find(@mdd.id).value.should include @institutional_group1
          MetaDatumInstitutionalGroups.find(@mdd.id).value.should include @institutional_group2
        end

      end

    end

  end

end
