module LdapHelper

  class << self 

    def fetch_from_ldap
      ldap_config ||= YAML::load_file("#{Rails.root}/tmp/ldap.yml")

      ldap = Net::LDAP.new :host => ldap_config[Rails.env]["host"],
        :port => ldap_config[Rails.env]["port"].to_i,
        :encryption => ldap_config[Rails.env]["encryption"].to_sym,
        :base => ldap_config[Rails.env]["base"],
        :auth => {
        :method=> :simple,
        :username => ldap_config[Rails.env]["bind_dn"],
        :password => ldap_config[Rails.env]["bind_pwd"] } 

      if ldap.bind
        #ic = Iconv.new('utf-8//IGNORE//TRANSLIT', 'utf-8')
        entries = []
        ldap.search(:attributes => ["name", "extensionAttribute1", "extensionAttribute3"], 
                    :filter => nil,
                    :return_result => true ) do |entry|
          next if entry["extensionattribute3"].empty?
          entries << entry
                    end
        File.open("db/ldap.json",'w'){|f| f.write(entries.to_json)}
      end
    end

    def update_institutional_groups_from_ldap_localfile
      JSON.parse(File.read("db/ldap.json")).each do |entry|
        entry = entry["myhash"]
        begin
          next unless (entry["name"] and entry["extensionattribute1"] and entry["extensionattribute3"])
          r = InstitutionalGroup.find_or_create_by_ldap_id(:ldap_id => entry["extensionattribute3"].first)
          r.update_attributes(:ldap_name => entry["name"].first, :name => entry["extensionattribute1"].first)
        rescue
          raise entry.to_s
        end
      end
    end

  end

end

