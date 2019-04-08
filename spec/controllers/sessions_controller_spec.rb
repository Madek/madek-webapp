require 'spec_helper'
require 'pry'

describe SessionsController do

  describe 'Singing in via Shibboleth i.e. shib_sign_in ' do

    before :each do
      Settings.shibboleth_sign_in_enabled = true
      User.delete_all
      Person.delete_all
      request.env['HTTP_SURNAME'] = 'LASTNAME'
      request.env['HTTP_GIVENNAME'] = 'FIRSTNAME'
      request.env['HTTP_MAIL'] = 'FIRSTNAME.LASTNAME@example.com'
    end

    describe 'as a new user' do

      it 'creates a person/user given proper fields' do
        expect(User.all).to be_empty
        expect(Person.all).to be_empty

        get :shib_sign_in

        assert_response :redirect

        expect(Person.first.last_name).to be == 'LASTNAME'
        expect(Person.first.first_name).to be == 'FIRSTNAME'
        expect(User.first.email).to be == 'FIRSTNAME.LASTNAME@example.com'.downcase
      end
    end

    describe 'as an existing user' do
      before :each do
        @person = Person.create last_name: 'OLD_LASTNAME',
                                first_name: 'OLD_FIRSTNAME', subtype: 'Person'
        @user = FactoryGirl.create \
          :user, person: @person, email: 'FIRSTNAME.LASTNAME@example.com'.downcase
      end

      it 'passes through a `lang` parameter' do
        get :shib_sign_in, lang: 'en'
        expect(response).to redirect_to '/my?lang=en'
      end

      it 'signs in as the existing user and updates attributes' do
        get :shib_sign_in

        expect(response).to redirect_to '/my'

        expect(Person.first.last_name).to be == 'LASTNAME'
        expect(Person.first.first_name).to be == 'FIRSTNAME'
        expect(User.first.email).to be == 'FIRSTNAME.LASTNAME@example.com'.downcase
      end
    end
  end

end
