RSpec.configure do |c|
  c.alias_it_should_behave_like_to \
    :it_provides_reader_method_for,
    'it provides reader method for'
end

RSpec.shared_examples 'meta_datum' do |attr|

  it attr do
    model_name_singular = described_class.model_name.singular.to_sym
    resource = FactoryGirl.create(model_name_singular)
    meta_key = \
      (MetaKey.find_by_id(attr) \
       || FactoryGirl.create(:meta_key_text, id: attr))

    FactoryGirl.create \
      :meta_datum_text,
      Hash[:meta_key, meta_key,
           model_name_singular, resource]

    expect(resource.send(attr)).not_to be_empty
  end
end
