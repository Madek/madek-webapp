module ZHDK
  module Sort

    class << self
      # sorts nested structures of arrays and hashes recursively
      def nested_sort ha
        if ha.class == Array
          ha.map{ |x| nested_sort(x) }.sort
        elsif ha.class == Hash or ha.class ==  HashWithIndifferentAccess
          Hash[Hash[ha.map{|k,v| [k,nested_sort(v)] }].sort]
        else
          ha
        end
      end

    end
  end
end
