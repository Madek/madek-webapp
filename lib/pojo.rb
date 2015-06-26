# ruby's <tt>OpenStruct</tt> is 👍, but framework support is 💩.
# Instead of monkey-patching and possible breakage elsewhere
# we just make our own class ('Plain old javascript-ish object')

class Pojo < OpenStruct

  def initialize(hash_or_hashable)
    super(hash_or_hashable.to_h)
  end

  def to_a
    self.to_h.to_a
  end

  # workaround this fuckup:
  #
  #   OpenStruct.new({a:1}).as_json #=> {"table"=>{"a"=>1}}
  #
  def as_json(*)
    self.marshal_dump # just returns the internal hash store (@table)
  end
end
