RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_validates, 'validates'
end

RSpec.shared_examples 'presence of' do |attr|

  it "#{attr}" do
    resource = FactoryGirl.create described_class.model_name.singular.to_sym
    resource.send("#{attr}=", nil)
    expect { resource.save! }.to raise_error ActiveRecord::RecordInvalid
  end

end
