class Array
    # Ask an Array whether it shares the same elements with another Array, irrespective of order
      # Options
      # :allow_duplicates
      #   If set to true arrays with the same elements, but differing numbers of those elements
      #   are treated as the same.
      #   Examples
      #     [ :a ].same_elements?( [ :a, :a ] ) => false
      #     [ :a ].same_elements?( [ :a, :a ], :allow_duplicates => true) => true
      def same_elements? another_array, options = {}
        raise ArgumentError, "#{another_array.inspect} was expected to be an Array" unless another_array.kind_of?(Array)
        s = self
        a = another_array
        if options[:allow_duplicates]
          s = s.uniq
          a = a.uniq
        end

        return element_counts(s) == element_counts(a)
      end

  private

  def element_counts obj
    result = []
    obj.uniq.map { |e|
      [ e, obj.inject(0) { |i, e2| i + (e == e2 ? 1 : 0 ) } ]
    }.each { |p| result << p.first; result << p.last }
    Hash[ *result ]
  end
end