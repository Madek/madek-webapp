class InstitutionalGroup < Group

  has_and_belongs_to_many :meta_data, 
    join_table: :meta_data_institutional_groups,
    association_foreign_key: :meta_datum_id,
    foreign_key: :institutional_group_id
 

  default_scope lambda{order(:name)}

  scope :by_string, lambda {|s|
    a = /(.*) \((.*)\)/.match(s)
    name, institutional_group_name = [a[1], a[2]]
    where(:name => name, :institutional_group_name => institutional_group_name)
  }

  scope :without_semesters, lambda{where("institutional_group_name NOT SIMILAR TO '%_[0-9]{2}[A-Za-z]\.studierende'")}
  scope :without_verteilerlisten, lambda{where("institutional_group_name NOT SIMILAR TO 'Verteilerliste\.%'")}
  scope :without_personal, lambda{where("institutional_group_name NOT SIMILAR TO 'Personal\.%'")}
  
  def self.relevant
    self.without_semesters.without_personal.without_verteilerlisten
  end

  def to_s
    "#{name} (#{institutional_group_name})"
  end

  def to_limited_s(n = 80)
    n = n.to_i
    
    if to_s.mb_chars.size > n
      "#{to_s.mb_chars.limit(n)}..."
    else
      to_s
    end
  end

  def is_readonly?
    true
  end

end
