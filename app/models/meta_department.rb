class MetaDepartment < Group

  has_and_belongs_to_many :meta_data, 
    join_table: :meta_data_meta_departments,
    association_foreign_key: :meta_datum_id,
    foreign_key: :meta_department_id
 

  default_scope order(:name)

  scope :by_string, lambda {|s|
    a = /(.*) \((.*)\)/.match(s)
    name, ldap_name = [a[1], a[2]]
    where(:name => name, :ldap_name => ldap_name)
  }

  scope :without_semesters, where("ldap_name NOT SIMILAR TO '%_[0-9]{2}[A-Za-z]\.studierende'")
  scope :without_verteilerlisten, where("ldap_name NOT SIMILAR TO 'Verteilerliste\.%'")
  scope :without_rek, where("ldap_name NOT SIMILAR TO 'REK\.%'")
  scope :without_personal, where("ldap_name NOT SIMILAR TO 'Personal\.%'")
  scope :without_berechtigung, where("ldap_name NOT SIMILAR TO '%\.berechtigung\.%'")
  
  def self.relevant
    self.without_semesters.without_personal.without_rek.without_verteilerlisten.without_berechtigung
  end

  def to_s
    "#{name} (#{ldap_name})"
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
