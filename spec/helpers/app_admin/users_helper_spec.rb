require 'spec_helper'

describe AppAdmin::UsersHelper do
  describe "#generate_user_path" do
    before :each do
      @user = FactoryGirl.create :user
    end

    context "when the user is an admin" do
      it "generates path to admin user section" do
        AdminUser.create!(user: @user)
        expect(helper.generate_user_path(:app_admin_user, @user)).to be== app_admin_admin_user_path(@user)
      end
    end

    context "when the user is not an admin" do
      it "generates path to user section" do
        expect(helper.generate_user_path(:app_admin_user, @user)).to be== app_admin_user_path(@user)
      end
    end
  end
end
