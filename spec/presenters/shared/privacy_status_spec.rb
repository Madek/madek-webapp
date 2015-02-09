RSpec.configure do |c|
  c.alias_it_should_behave_like_to(:it_responds_to, 'it responds to')
end

RSpec.shared_examples 'privacy_status' do

  context 'privacy status' do

    before :example do
      @user = FactoryGirl.create(:user)
    end

    it 'public' do
      resource = FactoryGirl.create(resource_type,
                                    responsible_user: @user,
                                    get_metadata_and_previews: true)
      presenter = described_class.new(resource, @user)
      expect(presenter.privacy_status).to be == :public
    end

    context 'shared' do

      after :example do
        @presenter = described_class.new(@resource, @user)
        expect(@presenter.privacy_status).to be == :shared
      end

      it 'responsible user entrusted resource to other user' do
        @resource = FactoryGirl.create(resource_type,
                                       responsible_user: @user)
        FactoryGirl.create("#{resource_type}_user_permission".to_sym,
                           Hash[:get_metadata_and_previews, true,
                                resource_type, @resource])
      end

      it 'responsible user entrusted resource to other group' do
        @resource = FactoryGirl.create(resource_type,
                                       responsible_user: @user)
        FactoryGirl.create("#{resource_type}_group_permission".to_sym,
                           Hash[:get_metadata_and_previews, true,
                                resource_type, @resource])
      end

      it 'entrusted to user' do
        @resource = FactoryGirl.create(resource_type)
        FactoryGirl.create("#{resource_type}_user_permission".to_sym,
                           Hash[:user, @user,
                                :get_metadata_and_previews, true,
                                resource_type, @resource])
      end

    end

    it 'private' do
      resource = FactoryGirl.create(resource_type,
                                    responsible_user: @user)
      presenter = described_class.new(resource, @user)
      expect(presenter.privacy_status).to be == :private
    end

  end
end
