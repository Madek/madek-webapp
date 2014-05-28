class ActiveRecord::Relation

  alias_method :to_sql_prepared, :to_sql

  def to_sql
    ActiveRecord::Base.connection.unprepared_statement do
      to_sql_prepared
    end
  end

end
