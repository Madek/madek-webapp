class ApiTokenPolicy < DefaultPolicy

  def update_api_token?
    return false if record.revoked # can't be edited if revoked
    record.user_id == user.id
  end

end
