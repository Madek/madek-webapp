require 'spec_helper'

describe MetaDatumPeople do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_person}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_person).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_person).should be_persisted
    end

  end


  describe "Linking with People" do

    before :each do
      @mdp = FactoryGirl.create :meta_datum_person
      @person1 = FactoryGirl.create :person
      @person2 = FactoryGirl.create :person
    end

    it "should be possible to add a person w.o. error" do
      expect{@mdp.people << @person1}.not_to raise_error
    end

     it "should have persist added relations" do
      @mdp.people << @person1
      @mdp.people << @person2
      MetaDatumPeople.find(@mdp.id).people.should include @person1
      MetaDatumPeople.find(@mdp.id).people.should include @person2
    end

    describe "value interface" do
      it "should be an alias for people" do
        @mdp.people << @person1
        @mdp.people << @person2
        MetaDatumPeople.find(@mdp.id).value.should include @person1
        MetaDatumPeople.find(@mdp.id).value.should include @person2
      end
    end
   
  end


end

