RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_destroys, 'it destroys'
end

RSpec.shared_examples 'ineffective permissions' do

  it 'removes' do

    expect(described_class.find_by id: permission.id).to be
    described_class.destroy_ineffective
    expect(described_class.find_by id: permission.id).not_to be

  end

end
