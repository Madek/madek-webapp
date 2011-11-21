require 'rubygems'
require 'digest'

# Creates a user with a local DB login

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