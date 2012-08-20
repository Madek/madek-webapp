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

##########################################
  
=begin
  # FIXME
  def self.setup_ldapdata_from_localfile
    JSON.parse(File.read("db/ldap.json")) do |entry|
      r = self.find_or_create_by_ldap_id(:ldap_id => entry["extensionattribute3"].first)
      r.update_attributes(:ldap_name => entry["name"].first, :name => entry["extensionattribute1"].first) 
    end
  end
=end

end
