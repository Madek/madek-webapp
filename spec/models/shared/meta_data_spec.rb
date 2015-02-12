RSpec.configure do |c|
  c.alias_it_should_behave_like_to \
    :it_provides_reader_method_for,
    'it provides reader method for'
end

RSpec.shared_examples 'title' do

  before :example do
    # TODO: remove as soon as the madek:core meta data is part of the test db
    with_disabled_triggers do
      MetaKey.create id: 'madek:core:title',
                     meta_datum_object_type: 'MetaDatum::Text'
    end
  end

  it 'title' do
    model_name_singular = described_class.model_name.singular.to_sym
    resource = FactoryGirl.create(model_name_singular)

    meta_key = MetaKey.find_by_id('madek:core:title')

    # protect against strange bug/missing core meta_key
    throw 'core:title should be in db!!!' unless meta_key

    FactoryGirl.create \
      :meta_datum_text,
      Hash[:meta_key, meta_key,
           model_name_singular, resource]

    expect(resource.title).not_to be_empty
  end

end

RSpec.shared_examples 'description' do

  it 'description' do
    model_name_singular = described_class.model_name.singular.to_sym
    resource = FactoryGirl.create(model_name_singular)

    meta_key = \
      (MetaKey.find_by_id('description') \
        || FactoryGirl.create(:meta_key_text, id: 'description'))

    FactoryGirl.create \
      :meta_datum_text,
      Hash[:meta_key, meta_key,
           model_name_singular, resource]

    expect(resource.description).not_to be_empty
  end

end

RSpec.shared_examples 'keywords' do

  before :example do
    # TODO: remove as soon as the madek:core meta data is part of the test db
    with_disabled_triggers do
      MetaKey.create id: 'madek:core:keywords',
                     meta_datum_object_type: 'MetaDatum::Keyword'
    end
  end

  it 'keywords' do
    model_name_singular = described_class.model_name.singular.to_sym
    resource = FactoryGirl.create(model_name_singular)

    meta_key = MetaKey.find_by_id('madek:core:keywords')

    meta_datum = \
      FactoryGirl.create :meta_datum_keywords,
                         Hash[:meta_key, meta_key,
                              model_name_singular, resource]

    FactoryGirl.create(:keyword, meta_datum: meta_datum)

    expect(resource.keywords).not_to be_empty
  end

end
