RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_handles_properly, 'it handles properly'
end

RSpec.shared_examples 'redirection' do
  let(:model_name) do
    described_class.controller_name.classify.constantize.model_name
  end

  let(:plural) do
    model_name.singular == 'media_entry' ? 'entries' : model_name.plural
  end

  let(:model_name_id) do
    "#{model_name.singular}_id".to_sym
  end

  before :example do
    @resource = \
      FactoryGirl.create(model_name.singular,
                         get_metadata_and_previews: true)
  end

  context 'without subroute' do

    context 'if requested with UUID' do
      it 'returns 302 if primary custom url exists' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, true,
                                  model_name.singular, @resource])
        get :show, id: @resource.id
        redirect_path = "#{request.base_url}/#{plural}/#{@custom_url.id}"
        expect(response).to redirect_to redirect_path
      end

      it 'returns 200 if custom url does not exist' do
        get :show, id: @resource.id
        expect(response.status).to be == 200
      end

      it 'returns 200 if custom url exists but not primary' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, false,
                                  model_name.singular, @resource])
        get :show, id: @resource.id
        expect(response.status).to be == 200
      end
    end

    context 'if requested with custom url ID' do
      it 'returns 302 if custom url not primary' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, false,
                                  model_name.singular, @resource])
        get :show, id: @custom_url.id
        redirect_path = \
          "#{request.base_url}/#{plural}/#{@resource.id}"
        expect(response).to redirect_to redirect_path
      end

      it 'returns 200 if custom url is primary' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, true,
                                  model_name.singular, @resource])
        get :show, id: @custom_url.id
        expect(response.status).to be == 200
      end

      it 'returns 404 if custom url does not exist' do
        expect { get :show, id: 'blah' }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'with subroute ./more_data' do

    context 'if requested with UUID' do
      it 'returns 302 if primary custom url exists' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, true,
                                  model_name.singular, @resource])
        get :more_data, id: @resource.id
        redirect_path = \
          "#{request.base_url}/#{plural}/#{@custom_url.id}/more_data"
        expect(response).to redirect_to redirect_path
      end

      it 'returns 200 if custom url does not exist' do
        get :more_data, id: @resource.id
        expect(response.status).to be == 200
      end

      it 'returns 200 if custom url exists but not primary' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, false,
                                  model_name.singular, @resource])
        get :more_data, id: @resource.id
        expect(response.status).to be == 200
      end
    end

    context 'if requested with custom url ID' do
      it 'returns 302 if custom url not primary' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, false,
                                  model_name.singular, @resource])
        get :more_data, id: @custom_url.id
        redirect_path = \
          "#{request.base_url}/#{plural}/#{@resource.id}/more_data"
        expect(response).to redirect_to redirect_path
      end

      it 'returns 200 if custom url is primary' do
        @custom_url = create(:custom_url,
                             Hash[:is_primary, true,
                                  model_name.singular, @resource])
        get :more_data, id: @custom_url.id
        expect(response.status).to be == 200
      end

      it 'returns 404 if custom url does not exist' do
        expect { get :more_data, id: 'blah' }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
