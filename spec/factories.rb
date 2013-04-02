# encoding: utf-8

class ActiveRecord::Base

  def self.find_random 
    if not (find_by_sql "SELECT * FROM #{table_name} LIMIT 1").first 
      nil
    else
      (find_by_sql "SELECT * from #{table_name} WHERE id = (SELECT floor((max(id) - min(id) + 1) * random())::int  + min(id) from #{table_name});").first 
    end
  end

end



module FactoryHelper

  def self.rand_bool *opts
    bias = ((opts and opts[0]) or 0.5)
    raise "bias must be a real number within [0,1)" if bias < 0.0 or bias >= 1.0
    (rand < bias) ? true : false
  end

end
