# -*- encoding : utf-8 -*-

json.userpermissions do |json|
  @userpermissions.each do |userpermission|
    json.partial! userpermission
  end
end
