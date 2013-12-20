# encoding: utf-8

class ActiveRecord::Base
  def self.find_random 
    find_by_sql(%[ SELECT * FROM  #{table_name} OFFSET floor(random() * (select count(*) from users))  LIMIT 1 ]).first
  end
end


module FactoryHelper

  def self.rand_bool *opts
    bias = ((opts and opts[0]) or 0.5)
    raise "bias must be a real number within [0,1)" if bias < 0.0 or bias >= 1.0
    (rand < bias) ? true : false
  end

end
