RSpec.configure do |c|
  c.alias_it_should_behave_like_to(:it_can_be, 'it can be')
end

RSpec.shared_examples 'dumped' do
  def all_values(obj)
    if obj.is_a?(Hash)
      obj.values.map { |v| all_values(v) }.flatten
    else
      obj
    end
  end

  it 'dump' do
    p = described_class.new(object, object.responsible_user)
    d = p.dump

    expect(
      all_values(d)
        .all? { |v| not v.nil? }
    )
      .to be true

    expect(
      all_values(d)
        .all? { |v| not v.match(/ActiveRecord/) }
    )
      .to be true
  end
end
