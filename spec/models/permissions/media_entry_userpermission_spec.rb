require 'spec_helper'

describe Permissions::MediaEntryUserpermission do

  it "is creatable via a factory" do
    expect{ FactoryGirl.create :media_entry_userpermission}.not_to raise_error
  end


  context "User and MediaEntry " do 

    before :each do 
      @user = FactoryGirl.create :user
      @creator = FactoryGirl.create :user
      @media_entry = FactoryGirl.create :media_entry
    end


    describe "destroy_ineffective" do

      context " for permissions where the user is the reponsible_user" do
        before :each do 
          @permission= FactoryGirl.create(:media_entry_userpermission, 
                                          download: true,
                                          user: @media_entry.responsible_user)
        end

        it "removes" do
          expect(Permissions::MediaEntryUserpermission.find_by id: @permission.id).to be
          Permissions::MediaEntryUserpermission.destroy_ineffective
          expect(Permissions::MediaEntryUserpermission.find_by id: @permission.id).not_to be
        end


      end

      context "for permission where all permission values are false and user is not the responsible_user" do
        before :each do 
          @permission= FactoryGirl.create(:media_entry_userpermission, 
                                          view: false,
                                          download: false,
                                          edit: false,
                                          manage: false,
                                          user: (FactoryGirl.create :user),
                                          media_entry: @media_entry)
        end

        it "removes" do
          expect(Permissions::MediaEntryUserpermission.find_by id: @permission.id).to be
          Permissions::MediaEntryUserpermission.destroy_ineffective
          expect(Permissions::MediaEntryUserpermission.find_by id: @permission.id).not_to be
        end

      end

    end

  end

end
