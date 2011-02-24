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

  LDAP_CONFIG = YAML::load_file("#{Rails.root}/config/LDAP.yml")

  def self.fetch_from_ldap
    ldap = Net::LDAP.new :host => LDAP_CONFIG[Rails.env]["host"],
                         :port => LDAP_CONFIG[Rails.env]["port"].to_i,
                         :encryption => LDAP_CONFIG[Rails.env]["encryption"].to_sym,
                         :base => LDAP_CONFIG[Rails.env]["base"],
                         :auth => {
                           :method=> :simple,
                           :username => LDAP_CONFIG[Rails.env]["bind_dn"],
                           :password => LDAP_CONFIG[Rails.env]["bind_pwd"] } 

    if ldap.bind
      #ic = Iconv.new('utf-8//IGNORE//TRANSLIT', 'utf-8')
      transaction do
        ldap.search(:attributes => ["name", "extensionAttribute1", "extensionAttribute3"], # [ "cn" , "displayName", "extensionAttribute2"],
                    :filter => nil,
                    :return_result => true ) do |entry|
                      next if entry["extensionattribute3"].empty?
                      r = self.find_or_create_by_ldap_id(:ldap_id => entry["extensionattribute3"].first)
                      r.update_attributes(:ldap_name => entry["name"].first, :name => entry["extensionattribute1"].first) #ic.iconv(entry["displayname"].first)
        end
      end
    end
    
  end
  
end
