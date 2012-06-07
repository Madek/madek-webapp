require 'spec_helper'

describe MetaDatumUsers do

  describe "Creation" do

    it "should not raise an error " do
      expect {FactoryGirl.create :meta_datum_users}.not_to raise_error
    end

    it "should not be nil" do
      (FactoryGirl.create :meta_datum_users).should_not == nil
    end

    it "should be persisted" do
      (FactoryGirl.create :meta_datum_users).should be_persisted
    end

  end

  describe "Linking with Users" do

    before :each do
      @mdd = FactoryGirl.create :meta_datum_users
      @user1 = FactoryGirl.create :user
      @user2 = FactoryGirl.create :user
    end

    it "should be possible to add a term w.o. error" do
      expect{@mdd.users << @user1}.not_to raise_error
    end

    context "added relations" do 

      before :each do
        @mdd.users << @user1
        @mdd.users<< @user2
      end

      it "should have persist added relations" do
        MetaDatumUsers.find(@mdd.id).users.should include @user1
        MetaDatumUsers.find(@mdd.id).users.should include @user2
      end

      describe "value interface" do
        it "should be an alias for people" do
          MetaDatumUsers.find(@mdd.id).value.should include @user1
          MetaDatumUsers.find(@mdd.id).value.should include @user2
        end

      end

    end

  end

end

