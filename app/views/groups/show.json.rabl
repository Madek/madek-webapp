object @group
attributes :id, :name, :type

child @users do |user|
  attributes :id, :login

  node :lastname do |user|
    user.person.lastname
  end

  node :firstname do |user|
    user.person.firstname
  end

end
