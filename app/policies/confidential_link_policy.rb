class ConfidentialLinkPolicy < DefaultPolicy

  def show?
    record.user_id == user.id
  end

  def update?
    return false if record.revoked # can't be edited if revoked
    record.user_id == user.id
  end

end
