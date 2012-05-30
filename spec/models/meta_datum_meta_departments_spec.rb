require 'spec_helper'

describe MetaDatumDepartments do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_departments}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_departments).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_departments).should be_persisted
    end

  end

  describe "Linking with MetaDepartements" do

    before :each do
      @mdd = FactoryGirl.create :meta_datum_departments
      @meta_department1 = FactoryGirl.create :meta_department
      @meta_department2 = FactoryGirl.create :meta_department
    end

    it "should be possible to add a department w.o. error" do
      expect{@mdd.meta_departments << @meta_department1}.not_to raise_error
    end

    it "should not be possible to add a plain group as a meta_department " do
      expect{@mdd.meta_departments << (FactoryGirl.create :group)}.to raise_error
    end

    context "added relations" do 

      before :each do
        @mdd.meta_departments << @meta_department1
        @mdd.meta_departments<< @meta_department2
      end

      it "should have persist added relations" do
        MetaDatumDepartments.find(@mdd.id).meta_departments.should include @meta_department1
        MetaDatumDepartments.find(@mdd.id).meta_departments.should include @meta_department2
      end

      describe "value interface" do
        it "should be an alias for people" do
          MetaDatumDepartments.find(@mdd.id).value.should include @meta_department1
          MetaDatumDepartments.find(@mdd.id).value.should include @meta_department2
        end

      end

    end

  end

end

