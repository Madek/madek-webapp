require 'spec_helper'

describe SessionsController do

  context 'POST #sign in' do

    before :context do
      @user = FactoryGirl.create :user
    end

    it 'successful sign in and redirect to default path' do

      post :sign_in, login: @user.login, password: @user.password

      expect(session[:user_id]).to be
      assert_redirected_to my_dashboard_path
      expect(flash[:success]).to eq 'Sie haben sich angemeldet.'

    end

    it 'successful logout' do

      post :sign_in, login: @user.login, password: @user.password
      post :sign_out

      expect(session[:user_id]).to be_nil # session should be reseted
      expect(flash[:notice]).to eq 'Sie haben sich abgemeldet.'
      assert_redirected_to root_path

    end

    context 'unsuccessful login' do
      after :example do
        assert_redirected_to root_path
        expect(flash[:error]).to eq 'Falscher Benutzername/Passwort.'
      end

      it 'missing username' do
        post :sign_in, password: @user.password
      end

      it 'wrong username' do
        post :sign_in, login: Faker::Internet.user_name, password: @user.password
      end

      it 'missing password' do
        post :sign_in, login: @user.login
      end

      it 'wrong password' do
        post :sign_in, login: @user.login, password: Faker::Internet.password
      end
    end

  end

end
