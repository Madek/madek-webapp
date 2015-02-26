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
    dump = presenter.dump

    expect(
      all_values(dump)
        .all? { |v| not v.nil? }
    )
      .to be true

    expect(
      all_values(dump)
        .all? { |v| not v.match(/active.*record/i) }
    )
      .to be true
  end
end
