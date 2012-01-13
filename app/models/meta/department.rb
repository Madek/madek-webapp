class Meta::Department < Group

  default_scope order(:name)

  def to_s
    "#{name} (#{ldap_name})"
  end

  def to_limited_s(n = 80)
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
  

  def self.setup_ldapdata_from_localfile
    JSON.parse(File.read("db/ldap.json")) do |entry|
      r = self.find_or_create_by_ldap_id(:ldap_id => entry["extensionattribute3"].first)
      r.update_attributes(:ldap_name => entry["name"].first, :name => entry["extensionattribute1"].first) 
    end
  end

end
