
module DevelopmentHelpers

  AUTH_XML = {"memberof"=> {"group"=> ["zhdk/SER_SUP.alle",
    "zhdk/SER_SUP.personal", "zhdk/SER.personal", "zhdk/SER.alle",
    "zhdk/SER_SUP_ITZ.personal", "zhdk/personal", "zhdk/SER_SUP_ITZ.alle"]},
    "id"=>"0", "uniqueid"=>"e0|zhdk", "phone_private"=>nil,
    "local_username"=>"jdeveloper@login.itz", "phone_mobile"=>nil,
    "firstname"=>"Joe", "phone_business"=>nil, "lastname"=>"Developer",
    "phone_function"=>nil, "fax"=>nil, "email"=>"joe.developer@zhdk.ch"}



  def self.fetch_from_ldap
    ldap_config ||= YAML::load_file("#{Rails.root}/config/LDAP.yml")

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

end


