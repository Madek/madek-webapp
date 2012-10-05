module DevelopmentHelpers
  require 'rubygems'
  require 'digest'

  AUTH_XML = {"memberof"=> {"group"=> ["zhdk/SER_SUP.alle",
    "zhdk/SER_SUP.personal", "zhdk/SER.personal", "zhdk/SER.alle",
    "zhdk/SER_SUP_ITZ.personal", "zhdk/personal", "zhdk/SER_SUP_ITZ.alle"]},
    "id"=>"999999", "uniqueid"=>"e999999|zhdk", "phone_private"=>nil,
    "local_username"=>"jdeveloper@login.itz", "phone_mobile"=>nil,
    "firstname"=>"Joe", "phone_business"=>nil, "lastname"=>"Developer",
    "phone_function"=>nil, "fax"=>nil, "email"=>"joe.developer@zhdk.ch"}

  class << self 

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end


    def fetch_from_ldap
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


    def mkuser(firstname, lastname, email, username, password)
      crypted_password = Digest::SHA1.hexdigest(password)
      person = Person.find_or_create_by_firstname_and_lastname(:firstname => firstname,
                                                               :lastname => lastname)
      user = person.build_user(:login => username,
                               :email => email,
                               :password => crypted_password)
      user.usage_terms_accepted_at = DateTime.now
      if user.save
        return user
      else
        puts "Could not create user: #{user.errors.full_messages}"
        return false
      end
    end

  end

end


